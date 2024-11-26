import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:vive_app/domain/models/encuesta.dart';

class PollWidget extends StatefulWidget {
  final Function(String question, List<String> options, bool allowMultiple)
      onPollCreated;

  const PollWidget({super.key, required this.onPollCreated});

  @override
  State<PollWidget> createState() => _PollWidgetState();
}

class _PollWidgetState extends State<PollWidget> {
  final TextEditingController _questionController = TextEditingController();
  final List<TextEditingController> _optionControllers = [
    TextEditingController(),
    TextEditingController()
  ];
  bool allowMultipleResponses = false;

  void _addOption() {
    setState(() {
      _optionControllers.add(TextEditingController());
    });
  }

  void _removeOption(int index) {
    setState(() {
      if (_optionControllers.length > 1) {
        _optionControllers.removeAt(index);
      }
    });
  }

  void _createPoll() async {
    final question = _questionController.text.trim();
    final options =
        _optionControllers.map((controller) => controller.text.trim()).toList();

    if (question.isNotEmpty && options.any((option) => option.isNotEmpty)) {
      widget.onPollCreated(question, options, allowMultipleResponses);
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('Por favor, completa la pregunta y al menos una opción.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: SizedBox(
        width: MediaQuery.of(context).size.width * .8,
        height: MediaQuery.of(context).size.height * .6,
        child: Padding(
          padding: const EdgeInsets.all(25),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Crear Encuesta",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _questionController,
                  decoration: const InputDecoration(
                      labelText: "Pregunta de la encuesta"),
                ),
                const SizedBox(height: 20),
                const Text("Opciones:"),
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: _optionControllers.length,
                  itemBuilder: (context, index) {
                    return Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _optionControllers[index],
                            decoration: InputDecoration(
                              labelText: "Opción ${index + 1}",
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.remove_circle,
                              color: Colors.red),
                          onPressed: () => _removeOption(index),
                        ),
                      ],
                    );
                  },
                ),
                TextButton.icon(
                  onPressed: _addOption,
                  icon: const Icon(Icons.add_circle),
                  label: const Text("Agregar opción"),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Checkbox(
                      value: allowMultipleResponses,
                      onChanged: (value) {
                        setState(() {
                          allowMultipleResponses = value ?? false;
                        });
                      },
                    ),
                    const Text("Permitir múltiples respuestas")
                  ],
                ),
                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: _createPoll,
                  child: const Text("Crear Encuesta"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class PollResultsWidget extends StatelessWidget {
  final String question;
  final Map<String, int> results;
  final bool allowMultipleResponses;

  const PollResultsWidget({
    super.key,
    required this.question,
    required this.results,
    this.allowMultipleResponses = false,
  });

  @override
  Widget build(BuildContext context) {
    final totalVotes = results.values.fold<int>(0, (sum, votes) => sum + votes);

    return Card(
      margin: const EdgeInsets.all(10),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              question,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ...results.entries.map((entry) {
              final percentage =
                  totalVotes > 0 ? (entry.value / totalVotes) * 100 : 0;

              return Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(entry.key,
                            style: const TextStyle(fontSize: 16)),
                      ),
                      Text(
                          "${entry.value} votos (${percentage.toStringAsFixed(1)}%)"),
                    ],
                  ),
                  LinearProgressIndicator(
                    value: percentage / 100,
                    backgroundColor: Colors.grey.shade300,
                    color: Colors.blue,
                  ),
                  const SizedBox(height: 10),
                ],
              );
            }).toList(),
            Text("Total de votos: $totalVotes"),
          ],
        ),
      ),
    );
  }
}

class EncuestaWidget extends StatefulWidget {
  final Encuesta encuesta; // La encuesta a mostrar
  final String userId;
  final String userImage; // La imagen del usuario que va a responder
  final int votantes;
  EncuestaWidget(
      {required this.encuesta,
      required this.userId,
      required this.userImage,
      required this.votantes});

  @override
  _EncuestaWidgetState createState() => _EncuestaWidgetState();
}

class _EncuestaWidgetState extends State<EncuestaWidget> {
  List<String> respuestasSeleccionadas = [];
  Map<String, int> votosPorOpcion = {}; // Para contar los votos por opción
  Map<String, List<String>> usuariosPorOpcion =
      {}; // Mapa para almacenar los usuarios que votaron por cada opción
  Box? mensajesBox;
  @override
  void initState() {
    super.initState();
    _initializeBoxes();
    // Inicializar el conteo de votos y los usuarios por opción
    for (var opcion in widget.encuesta.opciones) {
      votosPorOpcion[opcion] = 0; // Inicializar votos en 0
      usuariosPorOpcion[opcion] = []; // Inicializar lista de usuarios
    }

    // Cargar respuestas existentes
    print("votantes:" + widget.votantes.toString());
    if (widget.encuesta.respuestas.isNotEmpty) {
      usuariosPorOpcion.addAll(widget.encuesta.respuestas);
      for (var opcion in usuariosPorOpcion.keys) {
        votosPorOpcion[opcion] = usuariosPorOpcion[opcion]?.length ?? 0;
      }
      print(usuariosPorOpcion.toString());

      // Inicializar respuestas seleccionadas
      respuestasSeleccionadas = widget.encuesta.respuestas.keys
          .where((opcion) =>
              widget.encuesta.respuestas[opcion]?.contains(widget.userImage) ??
              false)
          .toList();
    }
  }

  Future<void> _initializeBoxes() async {
    mensajesBox = await Hive.openBox('mensajes${widget.encuesta.grupoId}');
  }

  void guardarRespuestas() async {
    // Actualizamos el mapa de usuarios por opción en la encuesta
    Encuesta encuestaActualizada =
        widget.encuesta; // Obtenemos la encuesta actual
    encuestaActualizada.respuestas.clear();
    encuestaActualizada.respuestas.addAll(usuariosPorOpcion);
    // Convertimos la encuesta actualizada a Map para guardarla en Firestore
    Map<String, dynamic> encuestaMap = encuestaActualizada.toMap(true);

    // Guardamos la encuesta en Firestore con el ID de la encuesta
    try {
      await FirebaseFirestore.instance
          .collection('mensajes')
          .doc(encuestaActualizada.id) // El ID de la encuesta
          .update(encuestaMap);
      await mensajesBox?.put(encuestaActualizada.id,
          encuestaActualizada.toMap(false)); // Actualizamos el documento de la encuesta
      print('Respuestas guardadas con éxito');
    } catch (e) {
      print('Error al guardar las respuestas: $e');
    }
  }

  void manejarSeleccion(String opcion) {
    setState(() {
      if (widget.encuesta.permitirMultiplesRespuestas) {
        // Manejo de selección múltiple
        if (respuestasSeleccionadas.contains(opcion)) {
          respuestasSeleccionadas.remove(opcion);
          votosPorOpcion[opcion] = (votosPorOpcion[opcion] ?? 0) - 1;
          usuariosPorOpcion[opcion]
              ?.remove(widget.userImage); // Remover usuario
        } else {
          respuestasSeleccionadas.add(opcion);
          votosPorOpcion[opcion] = (votosPorOpcion[opcion] ?? 0) + 1;
          usuariosPorOpcion[opcion]?.add(widget.userImage); // Añadir usuario
        }
      } else {
        // Manejo de selección única
        if (respuestasSeleccionadas.isNotEmpty) {
          String opcionAnterior = respuestasSeleccionadas.first;
          votosPorOpcion[opcionAnterior] =
              (votosPorOpcion[opcionAnterior] ?? 0) - 1;
          usuariosPorOpcion[opcionAnterior]?.remove(
              widget.userImage); // Remover usuario de la opción anterior
        }
        respuestasSeleccionadas = [opcion];
        votosPorOpcion[opcion] = (votosPorOpcion[opcion] ?? 0) + 1;
        usuariosPorOpcion[opcion]
            ?.add(widget.userImage); // Añadir usuario a la nueva opción
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final totalVotos = votosPorOpcion.values.reduce((a, b) => a + b);

    return Container(
      padding: const EdgeInsets.all(15),
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 146, 177, 230),
        border: Border.all(color: Colors.blueAccent, width: 1),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          const BoxShadow(
            color: Colors.black12,
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              widget.encuesta.pregunta,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Colors.black87,
              ),
            ),
          ),
          const SizedBox(height: 3),
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  widget.encuesta.permitirMultiplesRespuestas
                      ? Icons.check_box
                      : Icons.check_circle_sharp,
                  size: 10,
                ),
                const SizedBox(width: 2),
                Text(
                  widget.encuesta.permitirMultiplesRespuestas
                      ? 'Selecciona múltiples opciones'
                      : 'Selecciona una opción',
                  style: const TextStyle(fontSize: 10),
                ),
              ],
            ),
          ),
          const SizedBox(height: 15),
          SizedBox(
            width: 400,
            height: 150,
            child: ListView.builder(
              itemCount: widget.encuesta.opciones.length,
              itemBuilder: (BuildContext context, int index) {
                String opcion = widget.encuesta.opciones[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: SizedBox(
                    width: 400,
                    height: 50,
                    child: Stack(
                      alignment: const Alignment(0, 0),
                      children: [
                        Align(
                          alignment: const Alignment(-1, 0),
                          child: widget.encuesta.permitirMultiplesRespuestas
                              ? Checkbox(
                                  value:
                                      respuestasSeleccionadas.contains(opcion),
                                  onChanged: (bool? value) {
                                    manejarSeleccion(opcion);
                                    guardarRespuestas();
                                  },
                                  activeColor: Colors.blueAccent,
                                )
                              : Transform.scale(
                                  scale: 1.5,
                                  child: Radio<String>(
                                    value: opcion,
                                    groupValue:
                                        respuestasSeleccionadas.isNotEmpty
                                            ? respuestasSeleccionadas.first
                                            : null,
                                    onChanged: (String? value) {
                                      manejarSeleccion(value!);
                                      guardarRespuestas();
                                    },
                                    activeColor: Colors.blueAccent,
                                  ),
                                ),
                        ),
                        Align(
                          alignment: const Alignment(.9, -.5),
                          child: Text(
                            '${votosPorOpcion[opcion]}\n votos',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                color: Colors.black54, fontSize: 10),
                          ),
                        ),
                        Align(
                          alignment: const Alignment(0, -.5),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                opcion,
                                style: const TextStyle(color: Colors.black54),
                              ),
                              const SizedBox(height: 2),
                              SizedBox(
                                width: 200,
                                height: 10,
                                child: LinearProgressIndicator(
                                  borderRadius: BorderRadius.circular(5),
                                  value: totalVotos > 0
                                      ? votosPorOpcion[opcion]! /
                                          widget.votantes
                                      : 0,
                                  backgroundColor: Colors.grey[300],
                                  color: Colors.blueAccent,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Align(
                          alignment: const Alignment(.9, 1),
                          child: SizedBox(
                            height: 15,
                            width: 70,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              reverse: true,
                              itemCount: usuariosPorOpcion[opcion]?.length ?? 0,
                              itemBuilder: (context, index) {
                                String usuarioId =
                                    usuariosPorOpcion[opcion]![index];
                                return Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 2),
                                  child: CircleAvatar(
                                    backgroundImage: NetworkImage(
                                      usuarioId,
                                    ),
                                    radius: 7,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
