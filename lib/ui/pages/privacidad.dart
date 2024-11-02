import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vive_app/domain/alerts/alertCargando.dart';
import 'package:vive_app/domain/alerts/alertError.dart';
import 'package:vive_app/domain/alerts/alertSuccess.dart';
import 'package:vive_app/domain/models/user.dart';
import 'package:vive_app/infrastructure/controllers/controllerUser.dart';
import 'package:vive_app/ui/components/btnCustom.dart';
import 'package:vive_app/ui/components/customTextfield1.dart';
import 'package:vive_app/utils/styles.dart';

class Privacidad extends StatefulWidget {
  const Privacidad({super.key});

  @override
  State<Privacidad> createState() => _PrivacidadState();
}

class _PrivacidadState extends State<Privacidad> {
  final TextEditingController passActual = TextEditingController();
  final TextEditingController passNueva = TextEditingController();
  final TextEditingController passConfirm = TextEditingController();
  final ControllerUser controllerUser = Get.find();

  bool _isPasswordSecure(String password) {
    if (password.length < 8) return false;

    if (!RegExp(r'[A-Z]').hasMatch(password)) return false;

    if (!RegExp(r'[a-z]').hasMatch(password)) return false;

    if (!RegExp(r'[0-9]').hasMatch(password)) return false;

    return true;
  }

  @override
  void dispose() {
    passActual.dispose();
    passNueva.dispose();
    passConfirm.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: primaryColor(),
        title: const Text(
          "Privacidad",
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),
                    Container(
                        width: 400,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: const Text(
                          "Contraseña Actual",
                          style: TextStyle(fontWeight: FontWeight.w600),
                        )),
                    const SizedBox(height: 20),
                    CustomTextField1(
                      isPassword: true,
                      text: "Contraseña Actual",
                      controller: passActual,
                    ),
                    const SizedBox(height: 20),
                    Container(
                        width: 400,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: const Text(
                          "Nueva Contraseña",
                          style: TextStyle(fontWeight: FontWeight.w600),
                        )),
                    const SizedBox(height: 20),
                    CustomTextField1(
                      isPassword: true,
                      text: "Nueva Contraseña",
                      controller: passNueva,
                    ),
                    const SizedBox(height: 20),
                    Container(
                        width: 400,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: const Text(
                          "Confirmar Contraseña",
                          style: TextStyle(fontWeight: FontWeight.w600),
                        )),
                    const SizedBox(height: 20),
                    CustomTextField1(
                      isPassword: true,
                      text: "Confirmar Contraseña",
                      controller: passConfirm,
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: BtnCustom(
                onPressed: () async {
                  if (!_isPasswordSecure(passNueva.text)) {
                    mostrarAlertaError(context,
                        "La contraseña debe tener al menos 8 caracteres, incluyendo almenos 1 mayúscula, 1 minúsculas y 1 número");
                    return;
                  }

                  if (passConfirm.text != passNueva.text) {
                    mostrarAlertaError(
                        context, "Las contraseñas no coinciden.");
                    return;
                  }

                  mostrarAlertaCargando(context, "Actualizando Contraseña...");

                  String encryptedPasswordActual =
                      Usuario.encryptPassword(passActual.text);

                  DocumentSnapshot documentSnapshot = await FirebaseFirestore
                      .instance
                      .collection('users')
                      .doc(controllerUser.user!.userId == ""
                          ? ""
                          : controllerUser.user!.userId)
                      .get();

                  if (documentSnapshot.exists) {
                    // Si el documento existe, accedemos a los datos
                    Map<String, dynamic>? userData =
                        documentSnapshot.data() as Map<String, dynamic>?;

                    Usuario user = Usuario.fromJson(userData!);

                    if (encryptedPasswordActual == user.password) {
                      // Actualiza la contraseña en Firestore
                      String encryptedPasswordNueva =
                          Usuario.encryptPassword(passNueva.text);

                      try {
                        await FirebaseFirestore.instance
                            .collection('users')
                            .doc(controllerUser.user!.userId)
                            .update({'password': encryptedPasswordNueva});
                        Navigator.of(context).pop();
                        mostrarAlertaSucces(
                            context, "Contraseña actualizada correctamente.", (){});
                      } catch (e) {
                        Navigator.of(context).pop();
                        mostrarAlertaError(
                            context, "Hemos presentado algunos errores.");
                      }
                    } else {
                      Navigator.of(context).pop();
                      mostrarAlertaError(
                          context, "Contraseña actual incorrecta.");
                    }
                  } else {
                    Navigator.of(context).pop();
                    mostrarAlertaError(context,
                        "Presentamos problemas por favor intenta mas tarde");
                  }
                },
                bg: primaryColor(),
                textColor: colorWhite(),
                text: "Guardar",
              ),
            ),
          ],
        ),
      ),
    );
  }
}
