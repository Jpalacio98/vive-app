import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:vive_app/domain/models/grupos.dart';
import 'package:vive_app/domain/models/mensaje.dart';
import 'package:vive_app/infrastructure/controllers/controllerUser.dart';
import 'package:vive_app/ui/components/searchBar.dart';
import 'package:vive_app/ui/pages/chat.dart';
import 'package:vive_app/ui/pages/crear-grupo.dart';
import 'package:vive_app/ui/components/customChatGrupo.dart';
import 'package:vive_app/ui/pages/donaciones.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late List<Grupos> misGrupos = [];
  late List<Map<dynamic, dynamic>> ultimosMensaje = [];
  Box? _gruposBox;
  Box? ultimoMensajeBox;
  final ControllerUser controllerUser = Get.find();
  String searchQuery = "";

  @override
  void initState() {
    super.initState();
    cargarGrupos();
  }

  Future<void> _initializeBoxes(Mensaje mensaje) async {
    Box? mensajesBox = await Hive.openBox('mensajes${mensaje.grupoId}');
    if (!mensajesBox.containsKey(mensaje.id)) {
      // print("no esta en local:" + mensaje.mensaje);
      final newMessage = Mensaje(
          imagen: mensaje.imagen,
          nombreUsuario: mensaje.nombreUsuario,
          id: mensaje.id,
          userId: mensaje.userId,
          grupoId: mensaje.grupoId,
          tipo: mensaje.tipo,
          mensaje: mensaje.mensaje,
          estado: false,
          fecha: mensaje.fecha);

      await mensajesBox.put(newMessage.id, newMessage.toMap(true));
      await ultimoMensajeBox!
          .put(mensaje.grupoId, newMessage.toMapUltimo(true, 1));

      ultimosMensaje = List<Map<dynamic, dynamic>>.from(ultimoMensajeBox!.values
          .map((e) => e as Map<dynamic, dynamic>)
          .toList());

      setState(() {});
    }
  }

  Widget buildMessagesList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('mensajes').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          if (snapshot.hasData) {
            for (var doc in snapshot.data!.docs) {
              final mensaje =
                  Mensaje.fromMap(doc.data() as Map<String, dynamic>);
              _initializeBoxes(mensaje);
            }
          }
        }
        return Container();
      },
    );
  }

  void cargarGrupos() async {
    _gruposBox = await Hive.openBox('grupos');
    ultimoMensajeBox = await Hive.openBox('ultimoMensaje');

    if (_gruposBox == null) return;
    final List<dynamic> gruposData = _gruposBox!.values.toList();
    setState(() {
      print("numero de grupos ${gruposData.length}");
      misGrupos = gruposData.map((e) => Grupos.fromMap(e)).toList();
      ultimosMensaje = ultimoMensajeBox!.values
          .map((e) => e as Map<dynamic, dynamic>)
          .toList();
    });
  }

  Widget buildGruposList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('miembros')
          .where('userId', isEqualTo: controllerUser.user!.userId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          if (snapshot.hasData) {
            for (var miembroDoc in snapshot.data!.docs) {
              String grupoId = miembroDoc['grupoId'];

              if (!_gruposBox!.containsKey(grupoId)) {
                FirebaseFirestore.instance
                    .collection('grupos')
                    .doc(grupoId)
                    .get()
                    .then((grupoDoc) {
                  if (grupoDoc.exists) {
                    saveGruposToHive(grupoDoc);
                  }
                }).catchError((error) {
                  print("Error fetching group: $error");
                });
              }
            }
          }
        }
        return Container();
      },
    );
  }

  void saveGruposToHive(DocumentSnapshot<Map<String, dynamic>> doc) async {
    if (!_gruposBox!.containsKey(doc.id)) {
      final grupo = Grupos(
          imagen: doc['imagen'] ?? "",
          id: doc.id,
          descripcion: doc['description'] ?? "",
          latitud: (doc['latitud'] ?? 0.0).toDouble(),
          longitud: (doc['longitud'] ?? 0.0).toDouble(),
          nombre: doc['nombre'] ?? "",
          tipoImagen: doc['tipoImagen'] ?? "",
          miembros: doc['miembros'] ?? 0);

      await _gruposBox!.put(grupo.id, grupo.toMap());

      if (!ultimoMensajeBox!.containsKey(doc.id)) {
        final defaultMessage = Mensaje(
          imagen: "",
          nombreUsuario: "system",
          id: "default_message",
          userId: "system",
          grupoId: doc.id,
          tipo: "text",
          mensaje: "No hay mensajes",
          fecha: DateTime.now(),
          estado: true,
        );

        ultimoMensajeBox!.put(doc.id, defaultMessage.toMap(true));
      }

      cargarGrupos();
    }
  }

  void eliminarGrupo(String grupoId) async {
    // Mostrar un cuadro de confirmación
    bool? confirmacion = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Eliminar grupo"),
          content:
              const Text("¿Estás seguro de que deseas eliminar este grupo?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false), // Cancelar
              child: const Text("Cancelar"),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true), // Confirmar
              child: const Text("Eliminar"),
            ),
          ],
        );
      },
    );

    if (confirmacion == true) {
      try {
        // Eliminar el grupo de Firebase
        await FirebaseFirestore.instance
            .collection('grupos')
            .doc(grupoId)
            .delete();
        await FirebaseFirestore.instance
            .collection('topics')
            .doc(grupoId)
            .delete();
        // Eliminar los mensajes asociados al grupo
        await FirebaseFirestore.instance
            .collection('mensajes')
            .where('grupoId', isEqualTo: grupoId)
            .get()
            .then((snapshot) {
          for (var doc in snapshot.docs) {
            doc.reference.delete();
          }
        });

        // Eliminar el grupo y sus mensajes de Hive
        await _gruposBox?.delete(grupoId);
        await Hive.deleteBoxFromDisk('mensajes$grupoId');
        await ultimoMensajeBox?.delete(grupoId);

        // Actualizar la lista local de grupos
        setState(() {
          misGrupos.removeWhere((grupo) => grupo.id == grupoId);
          ultimosMensaje.removeWhere((msg) => msg['grupoId'] == grupoId);
        });

        Get.snackbar("Éxito", "El grupo ha sido eliminado.");
      } catch (e) {
        Get.snackbar("Error", "No se pudo eliminar el grupo: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Crear un mapa para acceder a los grupos por su ID
    Map<String, Grupos> gruposMap = {
      for (var grupo in misGrupos) grupo.id: grupo,
    };

    // Crear una lista con los últimos mensajes y agregarle el grupo correspondiente
    List<Grupos?> gruposOrdenados = ultimosMensaje.map((msg) {
      String grupoId = msg['grupoId'];
      return gruposMap[grupoId];
    }).toList();

    // Filtrar grupos nulos y organizar según la fecha
    List<Grupos> gruposNoNulos =
        gruposOrdenados.where((grupo) => grupo != null).cast<Grupos>().toList();

    // Filtrar grupos por nombre si hay una búsqueda activa
    if (searchQuery.isNotEmpty) {
      gruposNoNulos = gruposNoNulos
          .where((grupo) =>
              grupo.nombre.toLowerCase().contains(searchQuery.toLowerCase()))
          .toList();
    }

    // Ordenar por fecha y mover los grupos con fecha nula al final
    gruposNoNulos.sort((a, b) {
      DateTime? fechaA = ultimosMensaje.firstWhere(
                  (msg) => msg['grupoId'] == a.id,
                  orElse: () => {'fecha': null})['fecha'] !=
              null
          ? DateTime.fromMillisecondsSinceEpoch(ultimosMensaje
              .firstWhere((msg) => msg['grupoId'] == a.id)['fecha'])
          : null;

      DateTime? fechaB = ultimosMensaje.firstWhere(
                  (msg) => msg['grupoId'] == b.id,
                  orElse: () => {'fecha': null})['fecha'] !=
              null
          ? DateTime.fromMillisecondsSinceEpoch(ultimosMensaje
              .firstWhere((msg) => msg['grupoId'] == b.id)['fecha'])
          : null;

      if (fechaA == null && fechaB == null) return 0; // Ambos son nulos
      if (fechaA == null) return 1; // Mover A al final
      if (fechaB == null) return -1; // Mover B al final
      return fechaB.compareTo(fechaA); // Ordenar de más reciente a más antiguo
    });

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(top: 50, right: 0, left: 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Image.asset(
                    "assets/logo_letras.png",
                    fit: BoxFit.cover,
                    width: 50,
                  ),
                ),
                IconButton(
                  onPressed: (){
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DonationsPage(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.volunteer_activism,size: 20,),
                  iconSize: 20,
                  color: const Color(0xFFA1D0FF),
                  )
              ],
            ),
            // Campo de búsqueda

            const SizedBox(height: 25),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 0),
              child: SearchBar1(
                onChanged: (value) {
                  setState(() {
                    searchQuery = value; // Actualiza la consulta de búsqueda
                  });
                },
              ),
            ),
            const SizedBox(height: 25),

            // Iterar sobre los grupos ordenados para construir widgets
            for (Grupos grupo in gruposNoNulos)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 0),
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Chat(
                          grupo: grupo,
                        ),
                      ),
                    );
                  },
                  onLongPress: () {
                    eliminarGrupo(
                        grupo.id); // Llama a la función para eliminar el grupo
                  },
                  child: CustomChatGrupo(
                    mensaje: ultimosMensaje.firstWhere(
                      (msg) => msg['grupoId'] == grupo.id,
                      orElse: () => {
                        'mensaje': 'No hay mensajes recientes',
                        'fecha': null,
                      },
                    ),
                    grupo: grupo,
                  ),
                ),
              ),

            const SizedBox(height: 80),
            buildGruposList(),
            buildMessagesList()
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CreateGrupo(),
            ),
          );
        },
        backgroundColor: const Color(0xFFA1D0FF),
        foregroundColor: Colors.white,
        child: const Icon(Icons.add_comment),
      ),
      floatingActionButtonLocation: CustomFloatingButtonLocation(
        offsetFromBottom: 80,
        offsetFromRight: 16,
      ),
    );
  }
}

class CustomFloatingButtonLocation extends FloatingActionButtonLocation {
  final double offsetFromBottom;
  final double offsetFromRight;

  CustomFloatingButtonLocation({
    this.offsetFromBottom = 100,
    this.offsetFromRight = 16,
  });

  @override
  Offset getOffset(ScaffoldPrelayoutGeometry scaffoldGeometry) {
    double fabX = scaffoldGeometry.scaffoldSize.width -
        scaffoldGeometry.floatingActionButtonSize.width -
        offsetFromRight;
    double fabY = scaffoldGeometry.scaffoldSize.height -
        scaffoldGeometry.floatingActionButtonSize.height -
        offsetFromBottom;

    return Offset(fabX, fabY);
  }
}


