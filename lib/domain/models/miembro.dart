class Miembro {
  final String grupoId;
  final String userId;
  final String tipo;
  final DateTime fecha;
  String deviceToken;

  Miembro(
      {required this.grupoId,
      required this.userId,
      required this.tipo,
      required this.fecha,
      this.deviceToken ="",});

  factory Miembro.fromJson(Map<String, dynamic> json) {
    print("Hol: ${json['grupoId']}");
    return Miembro(
      grupoId: json['grupoId'],
      userId: json['userId'],
      fecha: DateTime.fromMillisecondsSinceEpoch(json['fecha'] as int),
      tipo: json['tipo'],
      deviceToken: json['deviceToken'],
    );
  }

  factory Miembro.fromMap(Map<dynamic, dynamic> json) {
    return Miembro(
      grupoId: json['grupoId'],
      userId: json['userId'],
      fecha: DateTime.fromMillisecondsSinceEpoch(json['fecha'] as int),
      tipo: json['tipo'],
      deviceToken: json['deviceToken'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'grupoId': grupoId,
      'userId': userId,
      'fecha': fecha,
      'tipo': tipo,
      'deviceToken': deviceToken,
    };
  }

  Map<String, dynamic> toMap() {
    return {
      'grupoId': grupoId,
      'userId': userId,
      'fecha': fecha,
      'tipo': tipo,
      'deviceToken': deviceToken,
    };
  }
}
