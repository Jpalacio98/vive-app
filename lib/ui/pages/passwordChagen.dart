import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vive_app/domain/alerts/alertCargando.dart';
import 'package:vive_app/domain/alerts/alertError.dart';
import 'package:vive_app/domain/alerts/alertSuccess.dart';
import 'package:vive_app/domain/models/user.dart';
import 'package:vive_app/infrastructure/controllers/controllerUser.dart';
import 'package:vive_app/ui/components/customTextfield1.dart';
import 'package:vive_app/ui/pages/login.dart';
import 'package:vive_app/utils/styles.dart';

class ChagenPassword extends StatefulWidget {
  final String code;
  final String correo;

  const ChagenPassword({super.key, required this.code, required this.correo});

  @override
  State<ChagenPassword> createState() => _ChagenPasswordState();
}

class _ChagenPasswordState extends State<ChagenPassword> {
  TextEditingController password = TextEditingController();
  TextEditingController confirmPass = TextEditingController();
  TextEditingController codigo = TextEditingController();
  final ControllerUser controllerUser = Get.find();

  bool _isPasswordSecure(String password) {
    if (password.length < 8) return false;

    if (!RegExp(r'[A-Z]').hasMatch(password)) return false;

    if (!RegExp(r'[a-z]').hasMatch(password)) return false;

    if (!RegExp(r'[0-9]').hasMatch(password)) return false;

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: primaryColor(),
        title: const Text(
          "Cambiar Contraseña",
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  Container(
                    width: 400,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: const Text(
                      "Hemos enviado un código a tu correo.",
                      style: TextStyle(
                        fontSize: 17,
                        color: Colors.black87,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    width: 400,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: const Text(
                      "Código",
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(height: 20),
                  CustomTextField1(
                    text: "Código",
                    controller: codigo,
                  ),
                  const SizedBox(height: 20),
                  Container(
                    width: 400,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: const Text(
                      "Nueva Contraseña",
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(height: 20),
                  CustomTextField1(
                    text: "Nueva Contraseña",
                    controller: password,
                    isPassword: true,
                  ),
                  const SizedBox(height: 20),
                  Container(
                    width: 400,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: const Text(
                      "Confirmar Contraseña",
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(height: 20),
                  CustomTextField1(
                    text: "Confirmar Contraseña",
                    controller: confirmPass,
                    isPassword: true,
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  if (widget.code == codigo.text) {
                    if (!_isPasswordSecure(password.text)) {
                      mostrarAlertaError(context,
                          "La contraseña debe tener al menos 8 caracteres, incluyendo al menos 1 mayúscula, 1 minúscula y 1 número");
                      return;
                    }

                    if (password.text != confirmPass.text) {
                      mostrarAlertaError(
                          context, "Las contraseñas no coinciden.");
                      return;
                    }

                    mostrarAlertaCargando(
                        context, "Actualizando Contraseña...");

                    QuerySnapshot querySnapshot = await FirebaseFirestore
                        .instance
                        .collection('users')
                        .where('correo', isEqualTo: widget.correo)
                        .limit(1)
                        .get();

                    if (querySnapshot.docs.isNotEmpty) {
                      DocumentSnapshot documentSnapshot =
                          querySnapshot.docs.first;

                      String encryptedPasswordNueva =
                          Usuario.encryptPassword(password.text);

                      try {
                        await FirebaseFirestore.instance
                            .collection('users')
                            .doc(documentSnapshot.id)
                            .update({'password': encryptedPasswordNueva});

                        Navigator.of(context).pop();
                        mostrarAlertaSucces(
                            context, "Contraseña actualizada correctamente.",
                            () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const LoginScreen()),
                          );
                        });
                      } catch (e) {
                        Navigator.of(context).pop();
                        mostrarAlertaError(
                            context, "Hemos presentado algunos errores.");
                      }
                    } else {
                      Navigator.of(context).pop();
                      mostrarAlertaError(
                          context, "Usuario no encontrado. Intenta más tarde.");
                    }

                    return;
                  }
                  mostrarAlertaError(context, "El código es incorrecto");
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor(),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                child: const Text(
                  "Confirmar",
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
