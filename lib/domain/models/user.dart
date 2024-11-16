import 'dart:convert';
import 'package:crypto/crypto.dart';

class Usuario {
  late String correo;
  late String nombre;
  late String imageUrl;
  final String password;
  final String userId;
  String deviceToken;

  Usuario({
    required this.correo,
    required this.nombre,
    required this.imageUrl,
    required this.password,
    required this.userId,
    this.deviceToken ="", // Cambiar a parámetro opcional
  });
  Map<String, dynamic> toJson() {
    return {
      'correo': correo,
      'nombre': nombre,
      'imageUrl': imageUrl,
      'password': password,
      'userId': userId,
      'deviceToken': deviceToken, // Agregar deviceToken al JSON
    };
  }

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      correo: json['correo'],
      nombre: json['nombre'],
      imageUrl: json['imageUrl'],
      password: json['password'],
      userId: json['userId'],
      deviceToken: json['deviceToken'], // Cargar deviceToken
    );
  }

  factory Usuario.fromMap(Map<dynamic, dynamic> json) {
    return Usuario(
      correo: json['correo'] as String,
      nombre: json['nombre'] as String,
      imageUrl: json['imageUrl'] as String,
      password: json['password'] as String,
      userId: json['userId'] as String,
      deviceToken: json['deviceToken'], // Cargar deviceToken
    );
  }

  static String encryptPassword(String password) {
    var bytes = utf8.encode(password);
    var digest = sha256.convert(bytes);
    return digest.toString();
  }

  // Función para verificar si un token está en la lista
  void hasDeviceToken(String token) {
    deviceToken=token;
    
  }
}
