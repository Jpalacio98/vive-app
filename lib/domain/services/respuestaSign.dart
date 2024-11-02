import 'dart:io';
import 'package:flutter/material.dart';
import 'package:vive_app/domain/alerts/alertCargando.dart';
import 'package:vive_app/domain/alerts/alertError.dart';
import 'package:vive_app/domain/alerts/alertSuccess.dart';
import 'package:vive_app/infrastructure/repository/enviarCodigo.dart';
import 'package:vive_app/ui/pages/sign/creando.dart';
import 'package:vive_app/ui/pages/sign/sign2.dart';
import 'package:vive_app/ui/pages/sign/sign3.dart';
import 'package:vive_app/ui/pages/sign/sign4.dart';

//falta verificar que no exista un usuario con el correo

class RespuestaSign {
  static final RegExp emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  static enviarCodigo(String correo, BuildContext context) async {
    correo = correo.trim();
    if (correo.isEmpty) {
      mostrarAlertaError(context, "El correo es requerido.");
      return;
    } else if (!emailRegex.hasMatch(correo)) {
      mostrarAlertaError(context, "Por favor, ingresa un correo válido.");
      return;
    } else {
      FocusScope.of(context).unfocus();
      mostrarAlertaCargando(context, 'Cargando...');
      String code = EmailService.generarCodigoVerificacion();
      var resp = await EmailService.enviarCorreoVerificacion(correo, code);

      Navigator.of(context).pop();

      if (resp == "success") {
        FocusScope.of(context).unfocus();
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => Sign2(
                    code: code,
                    correo: correo,
                  )),
        );
        return;
      } else {
        mostrarAlertaError(context,
            "Ocurrió un error inesperado. No hemos podido enviar el codigo por email.");
        return;
      }
    }

    // mostrarAlertaPersonalizada(
    //   context,
    //   "¿Estás seguro de que quieres continuar?",
    //   Icons.info,
    //   onConfirm: () {
    //     // Aquí manejas la acción de confirmación
    //     print("Confirmado");
    //     Navigator.of(context).pop(); // Cierra el diálogo
    //   },
    // );
  }

  static Future<String> reenviarCodigo(
      String correo, BuildContext context) async {
    correo = correo.trim();
    FocusScope.of(context).unfocus();
    mostrarAlertaCargando(context, 'Cargando...');
    String code = EmailService.generarCodigoVerificacion();
    var resp = await EmailService.enviarCorreoVerificacion(correo, code);

    Navigator.of(context).pop();

    if (resp == "success") {
      mostrarAlertaSucces(context, "Codigo reenviado correctamente", () {
        
      });
      return code;
    } else {
      mostrarAlertaError(context,
          "Ocurrió un error inesperado. No hemos podido enviar el codigo por email.");
      return "";
    }
  }

  static verificarCodigo(
      {required String code,
      required String codeEscrito,
      required String correo,
      required BuildContext context}) {
    if (code == codeEscrito) {
      correo = correo.trim();
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => Sign3(correo: correo)),
      );
      return;
    }

    mostrarAlertaError(context, "Código incorrecto.");
    return;
  }

  static verificarImagenName(
      {required dynamic image,
      required BuildContext context,
      required String nombre,
      required String correo}) {
    if (image == null) {
      mostrarAlertaError(context, "Por favor selecciona una imagen.");
    } else if (nombre.isEmpty) {
      mostrarAlertaError(context, "Por favor ingresa tu nombre.");
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                Sign4(correo: correo, image: image, nombre: nombre.trim())),
      );
    }
  }

  static bool _isPasswordSecure(String password) {
    if (password.length < 8) return false;

    if (!RegExp(r'[A-Z]').hasMatch(password)) return false;

    if (!RegExp(r'[a-z]').hasMatch(password)) return false;

    if (!RegExp(r'[0-9]').hasMatch(password)) return false;

    return true;
  }

  static crearCuenta(
      {required String password,
      required String confirmPassword,
      required String nombre,
      required String correo,
      required File image,
      required BuildContext context,
      required String token}) {
    password = password.trim();
    confirmPassword = confirmPassword.trim();

    if (password.isEmpty) {
      mostrarAlertaError(context, "La contraseña no puede estar vacía.");
      return;
    }

    if (!_isPasswordSecure(password)) {
      mostrarAlertaError(context,
          "La contraseña debe tener al menos 8 caracteres, incluyendo almenos 1 mayúscula, 1 minúsculas y 1 número");
      return;
    }

    if (password != confirmPassword) {
      mostrarAlertaError(context, "Las contraseñas no coinciden.");
      return;
    }

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
          builder: (context) => LoadingAccountCreation(
                correo: correo,
                image: image,
                nombre: nombre,
                password: password,
                token: token,
              )),
      (Route<dynamic> route) => false,
    );
  }
}
