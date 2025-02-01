import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as dart_ui;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:vive_app/domain/alerts/alertCargando.dart';
import 'package:vive_app/domain/models/grupos.dart';
import 'package:vive_app/infrastructure/controllers/controllerUser.dart';
import 'package:vive_app/infrastructure/controllers/map.dart';
import 'package:vive_app/ui/pages/chat.dart'; // Cierra el diálogo
import 'package:vive_app/utils/styles.dart';
import 'package:flutter/services.dart' show rootBundle;

class MapaGrupos extends StatefulWidget {
  const MapaGrupos({super.key});

  @override
  State<MapaGrupos> createState() => _MapaGruposState();
}

class _MapaGruposState extends State<MapaGrupos> {
  GoogleMapController? _mapController;
  static late CameraPosition _cameraPosition;
  static final MapController controller = Get.find();
  final Set<Marker> _markers = {};
  bool _isMapReady = false;
  Grupos? _selectedGrupo;
  String? isUbicacion;
  final ControllerUser controllerUser = Get.find();
  double _filterDistance = 250.0;
  double tempDistance = 250.0;


  @override
  void initState() {
    super.initState();
    _cameraPosition = CameraPosition(
              target: LatLng(controller.latitud, controller.longitud),
              zoom: 18.0,
            );
    _initMapa();
  }

  Future<void> _initMapa() async {
    // // Intenta obtener la ubicación
    isUbicacion = await controller.getCurrentLocation();
    print("isUbicacion: ${isUbicacion}");
    // Si es éxito, actualiza la posición de la cámara y carga los grupos
    if (isUbicacion == 'exito') {
      // _updateCameraPosition();
      await fetchGruposAndAddMarkers();
    } else {
      _showLocationPermissionDialog();
    }
  }

  void _showLocationPermissionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // No se puede cerrar sin aceptar
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Permisos de ubicación'),
          content: const Text(
              'Esta aplicación requiere permisos de ubicación. Por favor, activa la ubicación.'),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () async {
                // Vuelve a intentar obtener la ubicación
                isUbicacion = await controller.getCurrentLocation();

                // Si la obtienes, cierra el diálogo y carga los grupos
                if (isUbicacion == 'exito') {
                  Navigator.of(context).pop(); // Cierra el diálogo
                  _updateCameraPosition();
                  await fetchGruposAndAddMarkers();
                }
              },
            ),
          ],
        );
      },
    );
  }

  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const int radiusEarthKm = 6371; // Radio de la Tierra en kilómetros
    final double dLat = degreesToRadians(lat2 - lat1);
    final double dLon = degreesToRadians(lon2 - lon1);

    final double a = (sin(dLat / 2) * sin(dLat / 2)) +
        cos(degreesToRadians(lat1)) *
            cos(degreesToRadians(lat2)) *
            (sin(dLon / 2) * sin(dLon / 2));
    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return radiusEarthKm * c; // Devuelve la distancia en kilómetros
  }

  double degreesToRadians(double degrees) {
    return degrees * pi / 180;
  }

  // Future<List<Grupos>> fetchGrupos() async {
  //   List<Grupos> gruposList = [];
  //   List<Grupos> gruposCercanos = [];

  //   try {
  //     QuerySnapshot querySnapshot =
  //         await FirebaseFirestore.instance.collection('grupos').get();

  //     gruposList = querySnapshot.docs.map((doc) {
  //       return Grupos.fromJson({
  //         ...doc.data() as Map<String, dynamic>,
  //       });
  //     }).toList();

  //     print("Grupos obtenidos: $gruposList");

  //     // Obtener la ubicación actual del usuario
  //     double userLat =
  //         controller.latitud; // Usa la latitud de la ubicación actual
  //     double userLon =
  //         controller.longitud; // Usa la longitud de la ubicación actual

  //     // Filtrar los grupos que estén a menos de 1 kilómetro
  //     gruposCercanos = gruposList.where((grupo) {
  //       double distance =
  //           calculateDistance(userLat, userLon, grupo.latitud, grupo.longitud);
  //       return distance <= 250.0; // Distancia menor o igual a 1 kilómetro
  //     }).toList();

  //     print("Grupos cercanos (menos de 1 km): $gruposCercanos");
  //   } catch (e) {
  //     print("Error al obtener grupos: $e");
  //   }

  //   return gruposList; // Devuelve solo los grupos cercanos
  // }

  Future<void> fetchGruposAndAddMarkers() async {
    _markers.clear(); 
    mostrarAlertaCargando(context, "Cargando Grupos...");
    List<Grupos> grupos = await fetchGrupos();

    if (grupos.isEmpty) {
      // print("No se encontraron grupos.");
      Navigator.of(context).pop();
      return;
    }

    for (var grupo in grupos) {
      _createMarkerIcon(grupo.id, grupo.imagen).then((icon) {
        setState(() {
          _markers.add(Marker(
            markerId: MarkerId(grupo.id),
            position: LatLng(grupo.latitud, grupo.longitud),
            icon: icon,
            onTap: () => _onMarkerTapped(grupo), // Detectar clic en el marcador
          ));
        });
      });
    }

    print("Marcadores agregados: ${_markers.length}");
    Navigator.of(context).pop();
  }

  Future<BitmapDescriptor> _createMarkerIcon(
      String grupoId, String imagen) async {
    Uint8List bytes;

    if (imagen.contains("imagen local")) {
      // Carga la imagen desde los assets
      bytes = await _loadAssetImage("assets/grupo.jpg");
    } else {
      // Realiza la solicitud HTTP para obtener la imagen desde la URL
      final response = await http.get(Uri.parse(imagen));
      if (response.statusCode == 200) {
        bytes = response.bodyBytes;
      } else {
        throw Exception('Error al cargar la imagen del ícono');
      }
    }

    return _createRoundedMarkerIcon(bytes);
  }

  Future<Uint8List> _loadAssetImage(String assetPath) async {
    final ByteData data = await rootBundle.load(assetPath);
    return data.buffer.asUint8List();
  }

  Future<BitmapDescriptor> _createRoundedMarkerIcon(Uint8List bytes) async {
    final codec = await dart_ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    final image = frame.image;

    final pictureRecorder = dart_ui.PictureRecorder();
    final canvas = Canvas(pictureRecorder);
    final paint = Paint()..isAntiAlias = true;

    const size = Size(120, 120);
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final radius = size.width / 2;

    // Dibuja un círculo en el centro
    canvas.drawCircle(Offset(radius, radius), radius, paint);

    // Redimensiona la imagen a la mayor escala posible
    final srcSize = Size(image.width.toDouble(), image.height.toDouble());
    final srcAspectRatio = srcSize.width / srcSize.height;
    final dstAspectRatio = size.width / size.height;

    Rect srcRect;
    if (srcAspectRatio > dstAspectRatio) {
      final newWidth = srcSize.height * dstAspectRatio;
      srcRect = Rect.fromLTWH(
        (srcSize.width - newWidth) / 2,
        0,
        newWidth,
        srcSize.height,
      );
    } else {
      final newHeight = srcSize.width / dstAspectRatio;
      srcRect = Rect.fromLTWH(
        0,
        (srcSize.height - newHeight) / 2,
        srcSize.width,
        newHeight,
      );
    }

    paint.blendMode = BlendMode.srcIn;
    canvas.drawImageRect(image, srcRect, rect, paint);

    final picture = pictureRecorder.endRecording();
    final roundedImage =
        await picture.toImage(size.width.toInt(), size.height.toInt());

    final byteData =
        await roundedImage.toByteData(format: dart_ui.ImageByteFormat.png);
    final uint8List = byteData!.buffer.asUint8List();

    return BitmapDescriptor.fromBytes(uint8List);
  }

  void _updateCameraPosition() {
    if (controller.latitud != 0.0 && controller.longitud != 0.0) {
      _cameraPosition = CameraPosition(
        target: LatLng(controller.latitud, controller.longitud),
        zoom: 18.0,
      );
      if (_mapController != null) {
        _mapController!
            .moveCamera(CameraUpdate.newCameraPosition(_cameraPosition));
      }
    }
  }

  void _onMarkerTapped(Grupos grupo) {
    setState(() {
      _selectedGrupo = grupo;
    });
    _showGrupoBottomSheet(grupo);
  }

  Future<bool> checkIfMember(String grupoId) async {
    try {
      final documentId = controllerUser.user!.userId + grupoId;
      DocumentSnapshot document = await FirebaseFirestore.instance
          .collection('miembros')
          .doc(documentId)
          .get();

      return document.exists;
    } catch (e) {
      print("Error al verificar membresía: $e");
      return false;
    }
  }

  void _showGrupoBottomSheet(Grupos grupo) async {
    bool esMiembro = await checkIfMember(grupo.id);

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          width: fullWidth(context),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                  borderRadius: BorderRadius.circular(50),
                  child: _selectedGrupo!.imagen != "imagen local"
                      ? Image.network(
                          _selectedGrupo!.imagen,
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                        )
                      : Image.asset(
                          "assets/grupo.jpg",
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                        )),
              const SizedBox(height: 16.0),
              Text(
                grupo.nombre,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8.0),
              Text(
                grupo.descripcion,
                style: const TextStyle(fontSize: 15),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              esMiembro
                  ? SizedBox(
                      width: 200,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Chat(
                                grupo: grupo,
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.blue,
                          backgroundColor: Colors.white,
                          side: const BorderSide(color: Colors.blue),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('Ver Chat'),
                      ),
                    )
                  : SizedBox(
                      width: 200,
                      child: ElevatedButton(
                        onPressed: () async {
                          mostrarAlertaCargando(
                              context, "Estamos añadiendote al grupo...");
                          await FirebaseFirestore.instance
                              .collection('miembros')
                              .doc(controllerUser.user!.userId + grupo.id)
                              .set({
                            'grupoId': grupo.id,
                            'userId': controllerUser.user!.userId,
                            'tipo': "miembro",
                            'fecha': DateTime.now().millisecondsSinceEpoch,
                          });

                          Navigator.of(context).pop();

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Chat(
                                grupo: grupo,
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.blue,
                          backgroundColor: Colors.white,
                          side: const BorderSide(color: Colors.blue),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('Unirse al grupo'),
                      ),
                    ),
            ],
          ),
        );
      },
    );
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFA1D0FF),
        title: const Text("Mapa de Grupos"),
      ),
      // Drawer para configurar la distancia
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Color(0xFFA1D0FF),
              ),
              child: Text(
                'Configuración',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.filter_alt,color: Color(0xFFA1D0FF)),
              title: const Text('Distancia de Filtro'),
              subtitle: Text('$_filterDistance km'),
              trailing: IconButton(
                icon: const Icon(Icons.edit,color: Color(0xFFA1D0FF)),
                onPressed: () {
                  _showDistanceConfigDialog();
                },
              ),
            ),
          ],
        ),
      ),
      body: GoogleMap(
        initialCameraPosition: _cameraPosition,
        markers: _markers,
        onMapCreated: (controller) {
          _mapController = controller;
          setState(() {
            _isMapReady = true;
          });
        },
      ),
    );
  }

  void _showDistanceConfigDialog() {
  showDialog(
    context: context,
    builder: (context) {
      return DistanceConfigDialog(
        initialDistance: _filterDistance,
        onDistanceChanged: (newDistance) {
          setState(() {
            _filterDistance = newDistance;
            fetchGruposAndAddMarkers();
          });
        },
      );
    },
  );
}

  // Actualiza la función de filtrar grupos con la nueva distancia
  Future<List<Grupos>> fetchGrupos() async {
    List<Grupos> gruposList = [];
    List<Grupos> gruposCercanos = [];

    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('grupos').get();

      gruposList = querySnapshot.docs.map((doc) {
        return Grupos.fromJson({
          ...doc.data() as Map<String, dynamic>,
        });
      }).toList();

      print("Grupos obtenidos: $gruposList");

      // Obtener la ubicación actual del usuario
      double userLat =
          controller.latitud; // Usa la latitud de la ubicación actual
      double userLon =
          controller.longitud; // Usa la longitud de la ubicación actual

      // Filtrar los grupos que estén a menos de la distancia configurada
      gruposCercanos = gruposList.where((grupo) {
        double distance =
            calculateDistance(userLat, userLon, grupo.latitud, grupo.longitud);
        return distance <= _filterDistance; // Usa la distancia configurada
      }).toList();

      print("Grupos cercanos (menos de $_filterDistance km): $gruposCercanos");
    } catch (e) {
      print("Error al obtener grupos: $e");
    }

    return gruposCercanos; // Devuelve solo los grupos cercanos
  }
}



class DistanceConfigDialog extends StatelessWidget {
  final double initialDistance;
  final ValueChanged<double> onDistanceChanged;

  const DistanceConfigDialog({
    Key? key,
    required this.initialDistance,
    required this.onDistanceChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double tempDistance = initialDistance;

    return AlertDialog(
      title: const Text("Configurar Distancia"),
      content: StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Slider(
                activeColor: Color(0xFFA1D0FF),
                value: tempDistance,
                min: 100.0,
                max: 100000.0,
                divisions: 100,
                label: "${tempDistance.toInt()} Km",
                onChanged: (value) {
                  setState(() {
                    tempDistance = value;
                  });
                },
              ),
              Text(
                "${tempDistance.toInt()} Km",
                style: const TextStyle(fontSize: 16),
              ),
            ],
          );
        },
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text("Cancelar",style: TextStyle(color: Color(0xFFA1D0FF)),),
        ),
        ElevatedButton(
          onPressed: () {
            onDistanceChanged(tempDistance);
            Navigator.of(context).pop();
          },
          style:ElevatedButton.styleFrom(
              //padding: const EdgeInsets.symmetric(vertical: 15),
              backgroundColor: const Color(0xFFA1D0FF),
            ),
          
          child: const Text("Aceptar",style: TextStyle(color: Colors.white),),
        ),
      ],
    );
  }
}
