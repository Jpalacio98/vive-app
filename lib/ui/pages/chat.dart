import 'dart:core';
import 'dart:io';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:vive_app/domain/models/encuesta.dart';
import 'package:vive_app/domain/models/grupos.dart';
import 'package:vive_app/domain/models/mensaje.dart';
import 'package:vive_app/domain/services/bloc/notifications_bloc.dart';
import 'package:vive_app/infrastructure/controllers/controllerUser.dart';
import 'package:vive_app/ui/pages/encuenta.dart';
import 'package:vive_app/ui/pages/home.dart';

class Chat extends StatefulWidget {
  final Grupos grupo;

  const Chat({
    super.key,
    required this.grupo,
  });

  @override
  State<Chat> createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  List<Map<dynamic, dynamic>> messages = [];

  final TextEditingController _messageController = TextEditingController();
  final ControllerUser controllerUser = Get.find();

  Box? mensajesBox;
  Box? ultimoMensajeBox;

  Mensaje? mensajes;

  @override
  void initState() {
    super.initState();
    _initializeBoxes();
  }

  Future<void> _initializeBoxes() async {
    mensajesBox = await Hive.openBox('mensajes${widget.grupo.id}');
    ultimoMensajeBox = await Hive.openBox('ultimoMensaje');
    _loadMessages();
  }

  Widget buildMessagesList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('mensajes')
          .where('grupoId', isEqualTo: widget.grupo.id)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          if (snapshot.hasData) {
            saveMessagesToHive(snapshot.data!.docs);
            print("Hola se guardo cuando no se debia perdon");
          }
        }
        return Container();
      },
    );
  }

  void saveMessagesToHive(List<QueryDocumentSnapshot> docs) async {
    for (var doc in docs) {
      final newMessage;
      if (!mensajesBox!.containsKey(doc.id)) {
        if (doc['tipo'] == "encuesta") {
          newMessage = Encuesta(
              imagen: doc['imagen'] ?? "",
              nombreUsuario: doc['nombreUsuario'] ?? "",
              id: doc.id,
              userId: doc['userId'],
              grupoId: doc['grupoId'],
              tipo: doc['tipo'],
              mensaje: doc['mensaje'],
              estado: true,
              fecha: DateTime.fromMillisecondsSinceEpoch(doc['fecha'] as int),
              pregunta: doc['pregunta'],
              opciones: List<String>.from(doc['opciones']),
              permitirMultiplesRespuestas: doc['permitirMultiplesRespuestas'],
              respuestas: mapeoRespuestas(doc),
              fechaCreacion: DateTime.fromMillisecondsSinceEpoch(
                  doc['fechaCreacion'] as int));

          print("estas son las respuestas" + doc['respuestas'].toString());
        } else {
          newMessage = Mensaje(
              imagen: doc['imagen'] ?? "",
              nombreUsuario: doc['nombreUsuario'] ?? "",
              id: doc.id,
              userId: doc['userId'],
              grupoId: doc['grupoId'],
              tipo: doc['tipo'],
              mensaje: doc['mensaje'],
              estado: true,
              fecha: DateTime.fromMillisecondsSinceEpoch(doc['fecha'] as int));
        }

        await mensajesBox!.put(newMessage.id, newMessage.toMap(true));

        _loadMessages();
      }
    }
  }

  Map<String, List<String>> mapeoRespuestas(
      dynamic doc) {
    // Declara el mapa donde se guardarán los resultados
    Map<String, List<String>> res = {};

    // Convierte 'respuestas' a un mapa
    Map respuestasMap = Map.from(doc['respuestas']);

    // Itera sobre las entradas de respuestasMap
    for (var entry in respuestasMap.entries) {
      String key = entry.key; // Clave del mapa
      List<String> value =
          List<String>.from(entry.value); // Valor convertido a lista

      // Añade al mapa 'res', combinando si ya existe la clave
      if (res.containsKey(key)) {
        res[key]!.addAll(value);
      } else {
        res[key] = value;
      }
    }

    return res;
  }

  void _loadMessages() {
    print("entre hasta aca");
    setState(() {
      for (var message in mensajesBox!.values) {
        final updatedMessage = Map<dynamic, dynamic>.from(message);
        updatedMessage['estado'] = true;
        mensajesBox!.put(message['id'], updatedMessage);
      }

      messages = mensajesBox!.values
          .map((e) => e as Map<dynamic, dynamic>)
          .toList()
        ..sort((a, b) => DateTime.fromMillisecondsSinceEpoch(a['fecha'])
            .compareTo(DateTime.fromMillisecondsSinceEpoch(b['fecha'])));

      if (messages.isNotEmpty) {
        ultimoMensajeBox!.put(widget.grupo.id, messages.last);
      } else {
        final defaultMessage = Mensaje(
          imagen: "",
          nombreUsuario: "system",
          id: "default_message",
          userId: "system",
          grupoId: widget.grupo.id,
          tipo: "text",
          mensaje: "No hay mensajes",
          fecha: DateTime.now(),
          estado: true,
        );

        ultimoMensajeBox!.put(widget.grupo.id, defaultMessage.toMap(true));
      }
    });
  }

  String generateUniqueId() {
    final now = DateTime.now().millisecondsSinceEpoch;
    final random = Random().nextInt(100000);
    return '$now$random';
  }

  Future<void> sendMessage() async {
    if (_messageController.text.isEmpty) return;

    var idMensaje = generateUniqueId();

    final newMessage = Mensaje(
      imagen: controllerUser.user!.imageUrl,
      nombreUsuario: controllerUser.user!.nombre,
      id: idMensaje,
      userId: controllerUser.user!.userId,
      grupoId: widget.grupo.id,
      tipo: "text",
      mensaje: _messageController.text,
      fecha: DateTime.now(),
      estado: true,
    );

    //send the message notification
    final notify = NotificationsBloc();
    final userToken = await notify.getToken();
    try{
      await notify.sendNotificationToTopic(widget.grupo.nombre,
        controllerUser.user!.nombre, _messageController.text, userToken);
    }catch(e){
      print("Error sending Notification: ${e.toString()}");
    }
    
    //
    await mensajesBox!.put(newMessage.id, newMessage.toMap(false));
    setState(() {
      messages.add(newMessage.toMap(false));
      _messageController.clear();
    });

    var mensajeData = mensajesBox?.get(idMensaje);
    if (mensajeData != null) {
      try {
        await FirebaseFirestore.instance
            .collection('mensajes')
            .doc(idMensaje)
            .set({
          'id': idMensaje,
          'imagen': controllerUser.user!.imageUrl,
          'nombreUsuario': controllerUser.user!.nombre,
          'userId': mensajeData['userId'],
          'grupoId': mensajeData['grupoId'],
          'tipo': mensajeData['tipo'],
          'mensaje': mensajeData['mensaje'],
          'fecha': DateTime.now().millisecondsSinceEpoch,
        });

        mensajeData['sent'] = true;
        await mensajesBox?.put(idMensaje, mensajeData);
        _loadMessages();
      } catch (e) {
        print("Error: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const Home()),
            );
          },
        ),
        titleSpacing: 0,
        foregroundColor: const Color.fromARGB(255, 0, 0, 0),
        title: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color.fromARGB(255, 94, 94, 94)
                        .withOpacity(0.3), // Color de la sombra
                    spreadRadius: 2, // Tamaño de la sombra
                    blurRadius: 5, // Suavidad de la sombra
                    offset: const Offset(0, 3), // Posición de la sombra
                  ),
                ],
              ),
              child: ClipOval(
                  child: widget.grupo.tipoImagen == "local"
                      ? (widget.grupo.imagen != "imagen local"
                          ? Image.file(
                              File(widget.grupo.imagen),
                              width: 40,
                              height: 40,
                              fit: BoxFit.cover,
                            )
                          : Container(
                              width: 40,
                              height: 40,
                              color: Colors.white,
                              child: const Icon(Icons.group)))
                      : widget.grupo.imagen != "imagen local"
                          ? Image.network(
                              widget.grupo.imagen,
                              width: 40,
                              height: 40,
                              fit: BoxFit.cover,
                            )
                          : Container(
                              width: 40,
                              height: 40,
                              color: Colors.white,
                              child: const Icon(Icons.group))),
            ),
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                widget.grupo.nombre,
                style: const TextStyle(fontSize: 18),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        actions: [
          TextButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => PollWidget(
                    onPollCreated: (question, options, allowMultiple) async {
                      // Aquí procesas la creación de la encuesta
                      print("Pregunta: $question");
                      print("Opciones: $options");
                      print("Permitir múltiples: $allowMultiple");
                      // Crea un "mensaje" de tipo encuesta
                      var idMensaje = generateUniqueId();
                      Encuesta encuestaMessage = Encuesta(
                          id: idMensaje,
                          pregunta: question,
                          opciones: options,
                          permitirMultiplesRespuestas: allowMultiple,
                          fechaCreacion: DateTime.now(),
                          imagen: controllerUser.user!.imageUrl,
                          nombreUsuario: controllerUser.user!.nombre,
                          userId: controllerUser.user!.userId,
                          grupoId: widget.grupo.id,
                          tipo: 'encuesta',
                          mensaje: question,
                          fecha: DateTime.now(),
                          estado: true,
                          respuestas: {});

                      // También puedes guardar este mensaje en Firestore si lo deseas.

                      await mensajesBox!.put(
                          encuestaMessage.id, encuestaMessage.toMap(false));
                      setState(() {
                        messages.add(encuestaMessage.toMap(false));
                      });
                      var mensajeData = mensajesBox?.get(idMensaje);
                      if (mensajeData != null) {
                        try {
                          await FirebaseFirestore.instance
                              .collection('mensajes')
                              .doc(idMensaje)
                              .set({
                            'id': idMensaje,
                            'imagen': controllerUser.user!.imageUrl,
                            'nombreUsuario': controllerUser.user!.nombre,
                            'userId': mensajeData['userId'],
                            'grupoId': mensajeData['grupoId'],
                            'tipo': mensajeData['tipo'],
                            'mensaje': mensajeData['mensaje'],
                            'fecha': DateTime.now().millisecondsSinceEpoch,
                            'pregunta': mensajeData['pregunta'],
                            'opciones':
                                List<String>.from(mensajeData['opciones']),
                            'permitirMultiplesRespuestas':
                                mensajeData['permitirMultiplesRespuestas'],
                            'fechaCreacion':
                                DateTime.fromMillisecondsSinceEpoch(
                                    mensajeData['fechaCreacion']),
                          });

                          mensajeData['sent'] = true;
                          await mensajesBox?.put(idMensaje, mensajeData);
                          _loadMessages();
                        } catch (e) {
                          print("Error: $e");
                        }
                      }
                      // Guarda o muestra el mensaje de encuesta
                    },
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: Colors.blueAccent,
                  borderRadius:
                      BorderRadius.circular(5), // Border radius mínimo
                ),
                child: const Icon(
                  Icons.fact_check,
                  color: Colors.white,
                ),
              )),
        ],
      ),
      body: Stack(
        children: [
          // Imagen de fondo
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                    "assets/fondo-chat.png"), // Reemplaza con la ruta de la imagen
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Contenido del chat (mensajes y campo de texto)
          Column(
            children: [
              buildMessagesList(),
              Expanded(
                child: messages.isEmpty
                    ? _buildWelcomeMessage()
                    : ListView.builder(
                        padding: const EdgeInsets.all(10),
                        itemCount: messages.length,
                        reverse: true, // Empezar desde los más recientes
                        itemBuilder: (context, index) {
                          final message = messages[messages.length - 1 - index];
                          return _buildMessage(message);
                        },
                      ),
              ),
              _buildMessageInput(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeMessage() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/logo.png', // Ruta del logo de tu app
            width: 100,
            height: 100,
          ),
          const SizedBox(height: 20),
          const Text(
            '¡Bienvenido al grupo!',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Aun no hay mensajes en el grupo.\n¡Comienza a enviar mensajes ahora!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  String formatDateTime(DateTime dateTime) {
    final DateTime now = DateTime.now();

    // Compara solo las fechas (sin horas, minutos o segundos)
    bool isToday = dateTime.year == now.year &&
        dateTime.month == now.month &&
        dateTime.day == now.day;
    String hours = dateTime.hour.toString().padLeft(2, '0');
    String minutes = dateTime.minute.toString().padLeft(2, '0');

    if (isToday) {
      // Formato de hora

      return '$hours:$minutes'; // Solo mostrar la hora
    } else {
      // Formato de fecha
      String day = dateTime.day.toString().padLeft(2, '0');
      String month = dateTime.month.toString().padLeft(2, '0');
      String year = dateTime.year.toString();
      return '$day/$month/$year $hours:$minutes'; // Mostrar fecha completa
    }
  }

  Widget _buildMessage(Map<dynamic, dynamic> message) {
    final isMe =
        message['userId'] == controllerUser.user!.userId ? true : false;

    // Convertir el timestamp a DateTime
    final DateTime fecha =
        DateTime.fromMillisecondsSinceEpoch(message['fecha']);

    // Formatear la fecha a una cadena legible usando la función creada
    String formattedDate = formatDateTime(fecha);
    if (message['tipo'] == 'encuesta') {
      // Mostrar la encuesta de manera especial
      Encuesta encuestamessage = Encuesta.fromMap(message);

      return Align(
          alignment: Alignment.center,
          child: EncuestaWidget(
              encuesta: encuestamessage,
              userId: controllerUser.user!.userId,
              userImage: controllerUser.user!.imageUrl,
              votantes: widget.grupo.miembros));
    }
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            !isMe
                ? Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color.fromARGB(255, 94, 94, 94)
                              .withOpacity(0.3), // Color de la sombra
                          spreadRadius: 2, // Tamaño de la sombra
                          blurRadius: 5, // Suavidad de la sombra
                          offset: const Offset(0, 3), // Posición de la sombra
                        ),
                      ],
                    ),
                    child: ClipOval(
                        child: message['imagen'] != ""
                            ? Image.network(
                                message['imagen'],
                                width: 40,
                                height: 40,
                                fit: BoxFit.cover,
                              )
                            : Container(
                                width: 40,
                                height: 40,
                                color: Colors.white,
                                child: const Icon(Icons.group))),
                  )
                : Container(),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.all(10),
              constraints: const BoxConstraints(maxWidth: 250, minWidth: 100),
              decoration: BoxDecoration(
                color: isMe
                    ? const Color.fromARGB(255, 146, 177, 230)
                    : const Color.fromARGB(255, 255, 255, 255),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(15),
                  topRight: const Radius.circular(15),
                  bottomLeft: isMe ? const Radius.circular(15) : Radius.zero,
                  bottomRight: isMe ? Radius.zero : const Radius.circular(15),
                ),
              ),
              child: Column(
                crossAxisAlignment:
                    isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 10,
                  ),
                  Text(
                    isMe
                        ? "Tú"
                        : message['nombreUsuario'] == ""
                            ? "Eliminado"
                            : message['nombreUsuario'],
                    style: TextStyle(
                        color: isMe
                            ? const Color.fromARGB(255, 255, 255, 255)
                            : const Color.fromARGB(221, 155, 190, 235),
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  ),
                  Text(
                    message['mensaje'],
                    style: TextStyle(
                      color: isMe
                          ? const Color.fromARGB(255, 255, 255, 255)
                          : Colors.black87,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        formattedDate, // Mostrar la fecha formateada
                        style: TextStyle(
                          color: isMe
                              ? const Color.fromARGB(255, 247, 237, 237)
                              : const Color.fromARGB(110, 0, 0, 0),
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 5),
                      message['sent'] == true
                          ? const Icon(Icons.check_circle,
                              color: Colors.white, size: 16)
                          : const Icon(Icons.access_time,
                              color: Colors.white, size: 16),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Escribe tu mensaje...',
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          FloatingActionButton(
            onPressed: sendMessage,
            backgroundColor: Colors.blueAccent,
            child: const Icon(Icons.send, color: Colors.white),
          ),
        ],
      ),
    );
  }
}
