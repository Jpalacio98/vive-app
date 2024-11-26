

class Grupos {
  final String descripcion;
  final String id;
  final String imagen;
  final String tipoImagen;
  final double latitud;
  final double longitud;
  final String nombre;
  final int miembros;


  Grupos({
    required this.nombre,
    required this.descripcion,
    required this.id,
    required this.imagen,
    required this.latitud,
    required this.longitud,
    required this.tipoImagen,
    required this.miembros
  });

  factory Grupos.fromJson(Map<String, dynamic> json) {

    return Grupos(
      tipoImagen: json['tipoImagen'] ?? "",
      nombre: json['nombre'],
      descripcion: json['description'],
      id: json['id'],
      imagen: json['imagen'],
      latitud: json['latitud'],
      longitud: json['longitud'],
      miembros: json['miembros']
    );
  }

  factory Grupos.fromMap(Map<dynamic, dynamic> json) {

    return Grupos(
      tipoImagen: json['tipoImagen']  ?? "",
      nombre: json['nombre'],
      descripcion: json['description'],
      id: json['id'],
      imagen: json['imagen'],
      latitud: json['latitud'],
      longitud: json['longitud'],
      miembros:json['miembros'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tipoImagen': tipoImagen,
      'description': descripcion,
      'nombre': nombre,
      'id': id,
      'imagen': imagen,
      'latitud': latitud,
      'longitud': longitud,
      'miembros': miembros,
    };
  }

   Map<dynamic, dynamic> toMap() {
    return {
      'tipoImagen': tipoImagen,
      'description': descripcion,
      'nombre': nombre,
      'id': id,
      'imagen': imagen,
      'latitud': latitud,
      'longitud': longitud,
      'miembros': miembros
    };
  }
}
