import 'dart:io';
import 'dart:math';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:vive_app/domain/alerts/alertCargando.dart';
import 'package:vive_app/domain/alerts/alertError.dart';
import 'package:vive_app/domain/models/grupos.dart';
import 'package:vive_app/domain/services/bloc/notifications_bloc.dart';
import 'package:vive_app/infrastructure/controllers/controllerUser.dart';
import 'package:vive_app/ui/components/customTextfield1.dart';
import 'package:vive_app/ui/components/textfieldDescripcion.dart';
import 'package:vive_app/ui/pages/chat.dart';
import 'package:vive_app/utils/styles.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Agregar para Firestore

class CreateGrupo extends StatefulWidget {
  const CreateGrupo({super.key});

  @override
  State<CreateGrupo> createState() => _CreateGrupoState();
}

class _CreateGrupoState extends State<CreateGrupo> {
  final TextEditingController controllerNombre = TextEditingController();
  var _image;
  final TextEditingController ControllerDescription = TextEditingController();
  ImagePicker picker = ImagePicker();
  List<Map<String, dynamic>> miembros = [];
  final ControllerUser controllerUser = Get.find();
  String uniqueId = "";
  String imagenGrupo = "";
  String nombreGrupo = "";

  Future<Position> _obtenerUbicacion() async {
    LocationPermission permiso = await Geolocator.checkPermission();
    if (permiso == LocationPermission.denied) {
      permiso = await Geolocator.requestPermission();
      if (permiso == LocationPermission.denied) {
        throw Exception('Los permisos de ubicación están denegados');
      }
    }
    return await Geolocator.getCurrentPosition(
        // ignore: deprecated_member_use
        desiredAccuracy: LocationAccuracy.high);
  }

  _camGaleria(bool op) async {
    XFile? image;
    image = op
        ? await picker.pickImage(source: ImageSource.camera, imageQuality: 50)
        : await picker.pickImage(source: ImageSource.gallery, imageQuality: 50);

    setState(() {
      _image = (image != null) ? File(image.path) : null;
    });
  }

  void _opcioncamara(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return SafeArea(
            child: Wrap(
              children: <Widget>[
                ListTile(
                    leading: const Icon(Icons.photo_library),
                    title: const Text('Imagen de Galeria'),
                    onTap: () {
                      _camGaleria(false);
                      Navigator.of(context).pop();
                    }),
                ListTile(
                  leading: const Icon(Icons.photo_camera),
                  title: const Text('Capturar Imagen'),
                  onTap: () {
                    _camGaleria(true);
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          );
        });
  }

  Future _mostrarDialogoBuscarUsuario(
      BuildContext context, Function actualizar) async {
    final TextEditingController correoController = TextEditingController();
    Stream<QuerySnapshot>? streamBusqueda;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: const Text(
                "Buscar Usuario",
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    keyboardType: TextInputType.name,
                    controller: correoController,
                    decoration:
                        const InputDecoration(labelText: 'Nombre del usuario'),
                    onChanged: (texto) {
                      // Actualiza el stream solo si hay texto
                      if (texto.isNotEmpty) {
                        setState(() {
                          streamBusqueda = FirebaseFirestore.instance
                              .collection('users')
                              .where('nombre', isGreaterThanOrEqualTo: texto)
                              .where('nombre',
                                  isLessThanOrEqualTo: '$texto\uf8ff')
                              .snapshots();
                        });
                      } else {
                        setState(() {
                          streamBusqueda =
                              null; // No mostrar resultados si el campo está vacío
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 20),
                  // Mostrar mensaje o resultados usando StreamBuilder
                  if (streamBusqueda == null)
                    const Text("Busca un usuario por su nombre"),
                  if (streamBusqueda != null)
                    StreamBuilder<QuerySnapshot>(
                      stream: streamBusqueda,
                      builder: (context, snapshot) {
                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return const Text("No se encontraron usuarios");
                        }

                        // Obtener usuarios excluyendo el usuario actual
                        List<Map<String, dynamic>> usuariosEncontrados =
                            snapshot.data!.docs
                                .where(
                                    (doc) =>
                                        doc['nombre'] !=
                                        controllerUser.user!.nombre)
                                .map((doc) => {
                                      'nombre': doc['nombre'],
                                      'foto': doc['imageUrl'],
                                      'userId': doc['userId'],
                                      'deviceToken': doc['deviceToken']
                                    })
                                .toList();

                        if (usuariosEncontrados.isEmpty) {
                          return const Text("No se encontraron usuarios");
                        }

                        // Usar Flexible para que la lista se ajuste al contenido disponible
                        return Flexible(
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: usuariosEncontrados.length,
                            itemBuilder: (context, index) {
                              final usuarioEncontrado =
                                  usuariosEncontrados[index];
                              return ListTile(
                                leading: CircleAvatar(
                                  backgroundImage:
                                      NetworkImage(usuarioEncontrado['foto']),
                                ),
                                title: Text(usuarioEncontrado['nombre']),
                                onTap: () {
                                  bool yaExiste = miembros.any((miembro) =>
                                      miembro['userId'] ==
                                      usuarioEncontrado['userId']);
                                  if (!yaExiste) {
                                    setState(() {
                                      miembros.add(
                                          usuarioEncontrado); // Actualizar la lista de miembros en el estado principal
                                    });

                                    actualizar();
                                    Navigator.of(context).pop();
                                  } else {
                                    _mostrarMensajeUsuarioYaAdd(context);
                                  }
                                },
                              );
                            },
                          ),
                        );
                      },
                    ),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text("Cerrar"),
                ),
              ],
            );
          },
        );
      },
    );
  }

// Mostrar mensaje de que el usuario ya fue añadido
  void _mostrarMensajeUsuarioYaAdd(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Usuario ya añadido"),
          content: const Text("Este usuario ya está en la lista de miembros."),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Cerrar"),
            ),
          ],
        );
      },
    );
  }

  // Método para eliminar un miembro de la lista
  void _eliminarMiembro(int index) {
    setState(() {
      miembros.removeAt(index);
    });
  }

  Box? _messageBox;
  bool _isConnected = false;
  final Connectivity _connectivity = Connectivity();

  void _initConnectivity() async {
    var connectivityResult = await _connectivity.checkConnectivity();

    setState(() {
      _isConnected = connectivityResult != ConnectivityResult.none;
    });
  }

  String generateUniqueId() {
    final now = DateTime.now().millisecondsSinceEpoch;
    final random = Random().nextInt(100000);
    return '$now$random';
  }

  void _saveMessageLocally(String description, String nombre) async {
    var grupo;
    if (nombre.isEmpty) {
      mostrarAlertaError(context, "El nombre del grupo no puede ser vacio.");
      return;
    }

    if (description.isEmpty) {
      mostrarAlertaError(
          context, "La descripcion del grupo no puede ser vacia.");
      return;
    }

    if (miembros.isEmpty) {
      mostrarAlertaError(context, "Debes añadir almenos un miembro.");
      return;
    }

    // Obtener la ubicación
    Position posicion;
    try {
      mostrarAlertaCargando(context, 'Creando Grupo...');
      posicion = await _obtenerUbicacion();
    } catch (e) {
      mostrarAlertaError(context, "No se pudo obtener la ubicación.");
      return;
    }

    double latitud = posicion.latitude;
    double longitud = posicion.longitude;

    String imagen = "imagen local";

    if (_image == null) {
      // aca la imagen es una de assets
      imagen = "imagen local";
    } else {
      String respustaImagen = await saveImage(_image);
      if (respustaImagen == "error") {
        imagen = "imagen local";
      } else {
        imagen = respustaImagen;
      }
    }

    await FirebaseFirestore.instance
        .collection('miembros')
        .doc(controllerUser.user!.userId + uniqueId)
        .set({
      'grupoId': uniqueId,
      'userId': controllerUser.user!.userId,
      'tipo': "admin",
      'imagen': controllerUser.user!.imageUrl,
      'fecha': DateTime.now().millisecondsSinceEpoch,
    });

    for (var miembro in miembros) {
      await FirebaseFirestore.instance
          .collection('miembros')
          .doc(miembro['userId'] + uniqueId)
          .set({
        'grupoId': uniqueId,
        'userId': miembro['userId'],
        'imagen': miembro['imagen'],
        'tipo': "miembro",
        'fecha': DateTime.now().millisecondsSinceEpoch,
        'deviceToken': miembro['deviceToken'],
      });
    }

    //base de datos local
    imagenGrupo = imagen;
    nombreGrupo = nombre;

    _messageBox?.add({
      'id': uniqueId,
      'description': description,
      'imagen': imagen,
      'tipoImagen': 'local',
      'nombre': nombre,
      'longitud': longitud,
      'latitud': latitud,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'sent': false,
    });

    if (_isConnected) {
      String imageStorage = "imagen local";

      if (_image != null) {
        String storage = await _uploadImage(_image, context);
        if (imageStorage == "error") {
          imageStorage = "imagen local";
        } else {
          imageStorage = storage;
        }
      }

      await FirebaseFirestore.instance.collection('grupos').doc(uniqueId).set({
        'id': uniqueId,
        'description': description,
        'imagen': imageStorage,
        'nombre': nombre,
        'longitud': longitud,
        'latitud': latitud,
        'tipoImagen': 'web',
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });

      int index = _messageBox?.values
              .toList()
              .indexWhere((grupo) => grupo['id'] == uniqueId) ??
          -1;
      if (index != -1) {
        grupo = _messageBox?.getAt(index);
        grupo['sent'] = true;
        _messageBox?.putAt(index, grupo);
      }
    }
    Navigator.of(context).pop();

    Grupos grupo2 = Grupos.fromMap(grupo ??
        Grupos(
            nombre: "",
            descripcion: "",
            id: "",
            imagen: "",
            latitud: 0,
            longitud: 0,
            tipoImagen: ""));

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => Chat(grupo: grupo2)),
      (Route<dynamic> route) => false,
    );
  }

  Future<String> _uploadImage(File image, BuildContext context) async {
    try {
      String name = generateUniqueId();
      Reference ref = FirebaseStorage.instance
          .ref()
          .child('grupos')
          .child('${name}image.jpg');

      UploadTask uploadTask = ref.putFile(image);
      await uploadTask.whenComplete(() => null);

      String imageUrl = await ref.getDownloadURL();
      return imageUrl;
      //return "imagen local";
    } catch (e) {
      return "error";
    }
  }

  Future<String> saveImage(File imageFile) async {
    try {
      final path = await getLocalPath();
      final uuid = generateUniqueId();
      final String fileName = 'image_$uuid.png';
      final File localFile = File('$path/$fileName');
      await localFile.writeAsBytes(await imageFile.readAsBytes());
      return '$path/$fileName';
    } catch (e) {
      return 'error';
    }
  }

  Future<String> getLocalPath() async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

Future<void> createTopicDocument(String topicName, List<String> deviceTokens) async {


  try {
    // Referencia a la colección "topics" en Firestore
    final topicsCollection = FirebaseFirestore.instance.collection('topics');

    // Crear el documento con el UID como ID
    await topicsCollection.doc(uniqueId).set({
      'uid': uniqueId,
      'TopicName': topicName,
      'members': deviceTokens,
    });

    print('Documento creado exitosamente con UID: $uniqueId');
  } catch (e) {
    print('Error al crear el documento: $e');
  }
}
  @override
  void initState() {
    super.initState();
    _initConnectivity();
    _messageBox = Hive.box('grupos');
    uniqueId = generateUniqueId();
  }

  @override
  Widget build(BuildContext context) {
    final notify = context.read<NotificationsBloc>();
    notify.requestPermission();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        foregroundColor: Colors.white,
        title: const Text(
          "Nuevo Grupo",
          style: TextStyle(
            color: Colors.white,
            fontSize: 17,
          ),
        ),
        backgroundColor: primaryColor(),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: SizedBox(
                    width: 400,
                    child: Text(
                      "Foto & Nombre",
                      style: TextStyle(fontWeight: FontWeight.w600),
                    )),
              ),
              SizedBox(
                width: 400,
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.only(left: 20),
                      width: 80,
                      child: InkWell(
                        onTap: () {
                          _opcioncamara(context);
                        },
                        child: Container(
                          width: 60,
                          height: 60,
                          padding: const EdgeInsets.all(0),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(75),
                              color: const Color.fromARGB(115, 197, 197, 197)),
                          child: ClipOval(
                            child: _image == null
                                ? const Icon(
                                    Icons.camera_alt,
                                    size: 25,
                                    color: Colors.white,
                                  )
                                : Image.file(_image!,
                                    width: 60, height: 60, fit: BoxFit.cover),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: CustomTextField1(
                        text: "Nombre del grupo",
                        controller: controllerNombre,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: SizedBox(
                    width: 400,
                    child: Text(
                      "Descripción del Grupo",
                      style: TextStyle(fontWeight: FontWeight.w600),
                    )),
              ),
              CustomTextFieldDescription(
                text: "Descripción del Grupo",
                controller: ControllerDescription,
                maxLines: 5, // O el número que desees
                minLines: 3,
              ),
              const SizedBox(
                height: 10,
              ),
//Image.file(File('/data/user/0/com.lessyngthon.vive_app/app_flutter/image_172911994123875502.png'))  mostrar imagen local

              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: SizedBox(
                    width: 400,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Text(
                              "Miembros: ",
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            Text(
                              miembros.length
                                  .toString(), // Mostrar el número de miembros
                              style:
                                  const TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            await _mostrarDialogoBuscarUsuario(context, () {
                              setState(() {});
                            });
                          },
                          style: ElevatedButton.styleFrom(
                              backgroundColor: bgPrincipal()),
                          child: Text(
                            "Añadir",
                            style: TextStyle(color: Colors.white),
                          ),
                        )
                      ],
                    )),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SizedBox(
                  width: 400,
                  child: Wrap(
                    children: miembros.map((usuario) {
                      int index = miembros.indexOf(usuario);
                      return Stack(
                        children: [
                          // Avatar y nombre
                          Column(
                            children: [
                              Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color:
                                        const Color.fromARGB(34, 33, 149, 243),
                                    width: 3.0,
                                  ),
                                ),
                                child: CircleAvatar(
                                  backgroundImage:
                                      NetworkImage(usuario['foto']),
                                ),
                              ),
                              SizedBox(
                                width: 80,
                                child: Text(
                                  usuario['nombre'],
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                          // Botón de eliminar en la esquina superior derecha
                          Positioned(
                            top: -5, // Ajusta la posición para que se vea bien
                            right:
                                -5, // Ajusta la posición para que se vea bien
                            child: IconButton(
                              icon: const Icon(Icons.close,
                                  size: 16, color: Colors.red),
                              onPressed: () {
                                // Lógica para eliminar el usuario de la lista
                                setState(() {
                                  miembros.removeAt(index);
                                });
                              },
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          _saveMessageLocally(
              ControllerDescription.text, controllerNombre.text);
          List<String> members = [];

          for (var member in miembros) {
            if (member.containsKey('userId') &&
                member['userId'] != null) {
              String token = member['userId'].toString();
              members.add(token);
            }
          }
          members.add(controllerUser.user!.userId);
          if (members.isEmpty) {
            print("Error: No se encontraron miembros con tokens válidos.");
            return;
          }

          print("Lista de miembros: $members");

          //final notifyService = NotificationsBloc();
          //await notifyService.createGroup(controllerNombre.text, members);
          await createTopicDocument(controllerNombre.text.trim(), members);
        },
        backgroundColor: bgPrincipal(),
        foregroundColor: Colors.white,
        child: const Icon(Icons.arrow_right_alt),
      ),
    );
  }
}
