class Miembro {
  final String grupoId;
  final String userId;
  final String tipo;
  final DateTime fecha;

  Miembro(
      {required this.grupoId,
      required this.userId,
      required this.tipo,
      required this.fecha});

  factory Miembro.fromJson(Map<String, dynamic> json) {
    print("Hol: ${json['grupoId']}");
    return Miembro(
      grupoId: json['grupoId'],
      userId: json['userId'],
      fecha: DateTime.fromMillisecondsSinceEpoch(json['fecha'] as int),
      tipo: json['tipo'],
    );
  }

  factory Miembro.fromMap(Map<dynamic, dynamic> json) {
    return Miembro(
      grupoId: json['grupoId'],
      userId: json['userId'],
      fecha: DateTime.fromMillisecondsSinceEpoch(json['fecha'] as int),
      tipo: json['tipo'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'grupoId': grupoId,
      'userId': userId,
      'fecha': fecha,
      'tipo': tipo,
    };
  }

  Map<String, dynamic> toMap() {
    return {
      'grupoId': grupoId,
      'userId': userId,
      'fecha': fecha,
      'tipo': tipo,
    };
  }
}
