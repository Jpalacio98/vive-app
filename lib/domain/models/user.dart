import 'dart:convert';
import 'package:crypto/crypto.dart';

class Usuario {
  late String correo;
  late String nombre;
  late String imageUrl;
  final String password;
  final String userId;
  List<String> deviceTokens;

  Usuario({
    required this.correo,
    required this.nombre,
    required this.imageUrl,
    required this.password,
    required this.userId,
    List<String>? deviceTokens, // Cambiar a parámetro opcional
  }) : deviceTokens = deviceTokens ?? [];
  Map<String, dynamic> toJson() {
    return {
      'correo': correo,
      'nombre': nombre,
      'imageUrl': imageUrl,
      'password': password,
      'userId': userId,
      'deviceTokens': deviceTokens, // Agregar deviceTokens al JSON
    };
  }

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      correo: json['correo'],
      nombre: json['nombre'],
      imageUrl: json['imageUrl'],
      password: json['password'],
      userId: json['userId'],
      deviceTokens: List<String>.from(json['deviceTokens'] ?? []), // Cargar deviceTokens
    );
  }

  factory Usuario.fromMap(Map<dynamic, dynamic> json) {
    return Usuario(
      correo: json['correo'] as String,
      nombre: json['nombre'] as String,
      imageUrl: json['imageUrl'] as String,
      password: json['password'] as String,
      userId: json['userId'] as String,
      deviceTokens: List<String>.from(json['deviceTokens'] ?? []), // Cargar deviceTokens
    );
  }

  static String encryptPassword(String password) {
    var bytes = utf8.encode(password);
    var digest = sha256.convert(bytes);
    return digest.toString();
  }

  // Función para verificar si un token está en la lista
  void hasDeviceToken(String token) {
    if(deviceTokens.contains(token)){
      return;
    }else{
      deviceTokens.add(token);
    }
  }
}
