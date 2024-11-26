import 'dart:convert';

import 'package:vive_app/domain/models/mensaje.dart';

class Encuesta extends Mensaje {
  // La clase Encuesta hereda de Mensaje
  final String pregunta;
  final List<String> opciones;
  final bool permitirMultiplesRespuestas;
  final DateTime fechaCreacion;
  final Map<String, List<String>> respuestas;

  Encuesta({
    required String id,
    required String userId,
    required String grupoId,
    required String tipo,
    required String mensaje,
    required DateTime fecha,
    required bool estado,
    required String nombreUsuario,
    required String imagen,
    required this.pregunta,
    required this.opciones,
    required this.permitirMultiplesRespuestas,
    required this.fechaCreacion,
    this.respuestas =const {},
  }) : super(
          id: id,
          userId: userId,
          grupoId: grupoId,
          tipo: tipo,
          mensaje: mensaje,
          fecha: fecha,
          estado: estado,
          nombreUsuario: nombreUsuario,
          imagen: imagen,
        );

  // Convertir la encuesta (que ahora incluye los atributos heredados) a un mapa
  @override
  Map<String, dynamic> toMap(bool sent) {
    // Modificado para aceptar `sent`
    // Llamamos al toMap() de la clase base (Mensaje) para incluir sus propiedades
    Map<String, dynamic> map =
        super.toMap(sent); // Casting explícito a Map<String, dynamic>
    // Añadimos las propiedades específicas de Encuesta
    map.addAll({
      'pregunta': pregunta,
      'opciones': opciones,
      'permitirMultiplesRespuestas': permitirMultiplesRespuestas,
      'fechaCreacion': fechaCreacion.millisecondsSinceEpoch,
      'respuestas': respuestas,
    });
    return map;
  }

  // Convertir la encuesta a JSON (ahora retorna Map<String, dynamic>, no String)
  @override
  Map<String, dynamic> toJson() =>
      toMap(true); // Devuelve un mapa, no una cadena

  // Crear una encuesta desde un mapa
  factory Encuesta.fromMap(Map<dynamic, dynamic> map) {
    return Encuesta(
      id: map['id'],
      userId: map['userId'],
      grupoId: map['grupoId'],
      tipo: map['tipo'],
      mensaje: map['mensaje'],
      fecha: DateTime.fromMillisecondsSinceEpoch(map['fecha']),
      estado: map['estado'],
      nombreUsuario: map['nombreUsuario'],
      imagen: map['imagen'],
      pregunta: map['pregunta'],
      opciones: List<String>.from(map['opciones']),
      permitirMultiplesRespuestas: map['permitirMultiplesRespuestas'],
      fechaCreacion: DateTime.fromMillisecondsSinceEpoch(map['fechaCreacion']),
      respuestas:Map<String, List<String>>.from(map['respuestas'] ?? {}),
    );
  }

  // Crear una encuesta desde JSON
  factory Encuesta.fromJson(String source) =>
      Encuesta.fromMap(json.decode(source));
}

class RespuestaEncuesta {
  final String idEncuesta;
  final String idUsuario;
  final List<String>
      respuestas; // Puede ser una lista si permiten múltiples respuestas

  RespuestaEncuesta({
    required this.idEncuesta,
    required this.idUsuario,
    required this.respuestas,
  });

  // Convertir la respuesta a un mapa para guardarla
  Map<String, dynamic> toMap() {
    return {
      'idEncuesta': idEncuesta,
      'idUsuario': idUsuario,
      'respuestas': respuestas,
    };
  }

  // Convertir la respuesta a JSON
  String toJson() => json.encode(toMap());

  // Crear una respuesta desde un mapa
  factory RespuestaEncuesta.fromMap(Map<String, dynamic> map) {
    return RespuestaEncuesta(
      idEncuesta: map['idEncuesta'],
      idUsuario: map['idUsuario'],
      respuestas: List<String>.from(map['respuestas']),
    );
  }

  // Crear una respuesta desde JSON
  factory RespuestaEncuesta.fromJson(String source) =>
      RespuestaEncuesta.fromMap(json.decode(source));
}
