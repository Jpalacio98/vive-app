class Mensaje {
  final String id;
  final String userId;
  final String grupoId;
  final String tipo;
  final String mensaje;
  final DateTime fecha;
  late bool estado;
  final String nombreUsuario;
  final String imagen;

  Mensaje({
    required this.id,
    required this.userId,
    required this.grupoId,
    required this.tipo,
    required this.mensaje,
    required this.fecha,
    required this.estado,
    required this.nombreUsuario,
    required this.imagen,
  });

  // Método para convertir la clase Mensaje a un JSON (serialización)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'estado': estado,
      'userId': userId,
      'grupoId': grupoId,
      'tipo': tipo,
      'mensaje': mensaje,
      'fecha': fecha.millisecondsSinceEpoch,
      'sent': true,
      'nombreUsuario': nombreUsuario,
      'imagen': imagen,
    };
  }

  Map<String, dynamic> toMap(bool sent) {
    return {
      'id': id,
      'estado': estado,
      'userId': userId,
      'grupoId': grupoId,
      'tipo': tipo,
      'mensaje': mensaje,
      'fecha': fecha.millisecondsSinceEpoch,
      'sent': sent,
      'nombreUsuario': nombreUsuario,
      'imagen': imagen,
    };
  }

  Map<dynamic, dynamic> toMapUltimo(bool sent, int numero) {
    return {
      'id': id,
      'estado': estado,
      'userId': userId,
      'grupoId': grupoId,
      'tipo': tipo,
      'mensaje': mensaje,
      'fecha': fecha.millisecondsSinceEpoch,
      'sent': sent,
      'nombreUsuario': nombreUsuario,
      'imagen': imagen,
      'num': numero
      
    };
  }

  // Método para crear una instancia de Mensaje desde un JSON (deserialización)
  factory Mensaje.fromJson(Map<String, dynamic> json) {
    return Mensaje(
      imagen: json['imagen'] ?? "",
      nombreUsuario: json['nombreUsuario'] ?? "",
      estado: json['estado'] ?? false,
      id: json['id'] as String,
      userId: json['userId'] as String,
      grupoId: json['grupoId'] as String,
      tipo: json['tipo'] as String,
      mensaje: json['mensaje'] as String,
      fecha: DateTime.fromMillisecondsSinceEpoch(
          json['fecha'] as int), // Convierte timestamp a DateTime
    );
  }

  // Método para crear una instancia de Mensaje desde un Map (puedes usar este en lugar de fromJson si prefieres Map)
  factory Mensaje.fromMap(Map<dynamic, dynamic> map) {
    return Mensaje(
      imagen: map['imagen'] ?? "",
      nombreUsuario: map['nombreUsuario'] ?? "",
      estado: map['estado'] ?? false,
      id: map['id'] as String,
      userId: map['userId'] as String,
      grupoId: map['grupoId'] as String,
      tipo: map['tipo'] as String,
      mensaje: map['mensaje'] as String,
      fecha: DateTime.fromMillisecondsSinceEpoch(map['fecha'] as int),
    );
  }
}
