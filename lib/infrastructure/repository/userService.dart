// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:vive_app/domain/alerts/alertCargando.dart';
import 'package:vive_app/domain/alerts/alertError.dart';
import 'package:vive_app/domain/models/user.dart';
import 'package:vive_app/infrastructure/controllers/controllerUser.dart';
import 'package:vive_app/infrastructure/repository/generateId.dart';
import 'package:vive_app/ui/pages/home.dart';
import 'package:vive_app/ui/pages/init.dart';
import 'package:vive_app/ui/pages/sign/errorView.dart';
import 'package:vive_app/ui/pages/sign/successView.dart';

class UserService {
  static Future<bool> login(String email, String password, BuildContext context,
      bool isChecked, Box? authLocal,String token) async {
    try {
      mostrarAlertaCargando(context, "Iniciando Sesión...");
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('correo', isEqualTo: email)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        var userData = querySnapshot.docs.first.data() as Map<String, dynamic>;

        if (userData['password'] == password) {
          Usuario user = Usuario.fromJson(userData);
          user.hasDeviceToken(token);
          user.hasDeviceToken(token);
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.userId)
          .update(user.toJson());

          final ControllerUser controlleruser = Get.find();
          controlleruser.DataUser(user);

          if (isChecked) {
            authLocal?.add({
              'correo': user.correo,
              'imageUrl': user.imageUrl,
              'nombre': user.nombre,
              'password': user.password,
              'userId':user.userId,
              'deviceToken':user.deviceTokens
            });
          }

          Navigator.of(context).pop();

          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => const Home(),
            ),
            (Route<dynamic> route) => false,
          );

          return true;
        } else {
          Navigator.of(context).pop();
          mostrarAlertaError(context, "Contraseña incorrecta");
        }
      } else {
        Navigator.of(context).pop();
        mostrarAlertaError(context, "Usuario no encontrado");
      }
    } catch (e) {
      Navigator.of(context).pop();
      mostrarAlertaError(context, "Error al iniciar sesión: $e");
    }

    return false;
  }

  static Future<String?> _uploadImage(
      File image, String userId, BuildContext context) async {
    try {
      Reference ref = FirebaseStorage.instance
          .ref()
          .child('users')
          .child(userId)
          .child('profile.jpg');

      UploadTask uploadTask = ref.putFile(image);
      await uploadTask.whenComplete(() => null);

      String imageUrl = await ref.getDownloadURL();
      return imageUrl;
    } catch (e) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => ErrorView(
            errorMessage: "Error al subir la imagen: $e",
            onRetry: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => const InitPage(),
                ),
                (Route<dynamic> route) => false,
              );
            },
          ),
        ),
        (Route<dynamic> route) => false,
      );
      return null;
    }
  }

  static Future<bool> isEmailUnique(String correo, BuildContext context) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('correo', isEqualTo: correo)
          .get();

      return querySnapshot.docs.isEmpty;
    } catch (e) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => ErrorView(
            errorMessage: "Error al verificar el correo: $e",
            onRetry: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => const InitPage(),
                ),
                (Route<dynamic> route) => false,
              );
            },
          ),
        ),
        (Route<dynamic> route) => false,
      );
      return false;
    }
  }

  static Future<void> registerUser({
    required BuildContext context,
    required String correo,
    required String password,
    required String nombre,
    required File image,
    required String token,
  }) async {
    try {
      bool isUnique = await isEmailUnique(correo, context);
      if (!isUnique) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => ErrorView(
              errorMessage:
                  "El usuario con el correo $correo ya se encuentra registrado.",
              onRetry: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const InitPage(),
                  ),
                  (Route<dynamic> route) => false,
                );
              },
            ),
          ),
          (Route<dynamic> route) => false,
        );
        return;
      }

      String userId = Generateid.generateUuid();

      String encryptedPassword = Usuario.encryptPassword(password);

      String? imageUrl = await _uploadImage(image, userId, context);

      if (imageUrl == null) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => ErrorView(
              errorMessage: "Error al subir la imagen.",
              onRetry: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const InitPage(),
                  ),
                  (Route<dynamic> route) => false,
                );
              },
            ),
          ),
          (Route<dynamic> route) => false,
        );
        return;
      }

      Usuario usuario = Usuario(
        correo: correo,
        nombre: nombre,
        imageUrl: imageUrl,
        password: encryptedPassword,
        userId: userId,
      );
      // final  notificationsBloc = NotificationsBloc();
      // final token  = await notificationsBloc.getToken();
      usuario.hasDeviceToken(token);
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .set(usuario.toJson());

      final ControllerUser controlleruser = Get.find();
      controlleruser.DataUser(usuario);

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => SuccessView(
            onContinue: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => const Home(),
                ),
                (Route<dynamic> route) => false,
              );
            },
          ),
        ),
        (Route<dynamic> route) => false,
      );
    } catch (e) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => ErrorView(
            errorMessage: "Error al registrar el usuario: $e",
            onRetry: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => const InitPage(),
                ),
                (Route<dynamic> route) => false,
              );
            },
          ),
        ),
        (Route<dynamic> route) => false,
      );
    }
  }
}
