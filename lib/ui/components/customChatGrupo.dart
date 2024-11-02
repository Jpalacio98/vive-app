import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:vive_app/domain/models/grupos.dart';
import 'package:vive_app/infrastructure/controllers/controllerUser.dart';

class CustomChatGrupo extends StatefulWidget {
  final Grupos grupo;
  final Map<dynamic, dynamic> mensaje;

  const CustomChatGrupo({
    super.key,
    required this.grupo,
    required this.mensaje,
  });

  @override
  _CustomChatGrupoState createState() => _CustomChatGrupoState();
}

class _CustomChatGrupoState extends State<CustomChatGrupo> {
  final ControllerUser controllerUser = Get.find();
  Box? mensajesBox;
  List<Map<dynamic, dynamic>> mensajesList = [];
  int cont = 0;

  String formatDateTime(int dateTime) {
    final DateTime dateTimeConverted =
        DateTime.fromMillisecondsSinceEpoch(dateTime);
    final DateTime now = DateTime.now();

    bool isToday = dateTimeConverted.year == now.year &&
        dateTimeConverted.month == now.month &&
        dateTimeConverted.day == now.day;
    String hours = dateTimeConverted.hour.toString().padLeft(2, '0');
    String minutes = dateTimeConverted.minute.toString().padLeft(2, '0');

    if (isToday) {
      return '$hours:$minutes';
    } else {
      String day = dateTimeConverted.day.toString().padLeft(2, '0');
      String month = dateTimeConverted.month.toString().padLeft(2, '0');
      String year = dateTimeConverted.year.toString();
      return '$day/$month/$year $hours:$minutes';
    }
  }

  @override
  void initState() {
    super.initState();
    // cargarMensajes();
  }

  // void cargarMensajes() async {
  //   mensajesBox = await Hive.openBox('mensajes${widget.grupo.id}');
  //   List<Map<dynamic, dynamic>> mensajesList =
  //       List<Map<dynamic, dynamic>>.from(mensajesBox?.values.toList() ?? []);

  //   cont = mensajesList.where((message) => message['estado'] == false).length;
  //   print("Hola: $cont");

  //   setState(() {});
  // }

  // @override
  // void didUpdateWidget(CustomChatGrupo oldWidget) {
  //   super.didUpdateWidget(oldWidget);
  //   cargarMensajes();
  // }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color.fromARGB(62, 80, 80, 80).withOpacity(0.2),
                  spreadRadius: 2,
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: ClipOval(
              child: widget.grupo.tipoImagen == "local"
                  ? (widget.grupo.imagen == "imagen local" ||
                          widget.grupo.imagen == ""
                      ? Image.asset(
                          'assets/grupo.jpg',
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                        )
                      : Image.file(
                          File(widget.grupo.imagen),
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                        ))
                  : (widget.grupo.imagen == "imagen local" ||
                          widget.grupo.imagen == ""
                      ? Image.asset(
                          'assets/grupo.jpg',
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                        )
                      : Image.network(
                          widget.grupo.imagen,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                        )),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        widget.grupo.nombre,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      widget.mensaje['fecha'] == null
                          ? ''
                          : formatDateTime(widget.mensaje['fecha']),
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget.mensaje['mensaje'],
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    widget.mensaje['userId'] == controllerUser.user!.userId
                        ? (widget.mensaje['sent'] == true
                            ? const Icon(
                                Icons.check_circle,
                                color: Color.fromARGB(255, 165, 194, 243),
                                size: 22,
                              )
                            : const Icon(Icons.access_time,
                                color: Color.fromARGB(255, 165, 194, 243),
                                size: 22))
                        : Container(
                            height: 20,
                            constraints: const BoxConstraints(
                              minWidth: 20,
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 165, 194, 243),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Center(
                              // child: Text(
                              //   '$cont',
                              //   style: const TextStyle(
                              //     color: Colors.white,
                              //     fontSize: 10,
                              //     fontWeight: FontWeight.bold,
                              //   ),
                              // ),
                            ),
                          )
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
