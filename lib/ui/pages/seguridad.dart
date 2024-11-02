import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:vive_app/domain/alerts/alertCargando.dart';
import 'package:vive_app/domain/alerts/alertError.dart';
import 'package:vive_app/domain/alerts/alertSuccess.dart';
import 'package:vive_app/domain/models/user.dart';
import 'package:vive_app/infrastructure/controllers/controllerUser.dart';
import 'package:vive_app/ui/components/btnCustom.dart';
import 'package:vive_app/ui/components/customTextfield1.dart';
import 'package:vive_app/ui/pages/home.dart';
import 'package:vive_app/utils/styles.dart';

class Seguridad extends StatefulWidget {
  final String correo;
  final String nombre;
  final File? image;

  const Seguridad({
    super.key,
    required this.correo,
    required this.nombre,
    required this.image,
  });

  @override
  State<Seguridad> createState() => _SeguridadState();
}

class _SeguridadState extends State<Seguridad> {
  final TextEditingController password = TextEditingController();
  final ControllerUser controllerUser = Get.find();

  Box? _authBox;

  @override
  void initState() {
    super.initState();
    _authBox = Hive.box('auth');
  }

  @override
  void dispose() {
    password.dispose();
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
          "Seguridad",
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
                        "Necesitamos validar que seas tú.",
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
                        "Contraseña",
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                    const SizedBox(height: 20),
                    CustomTextField1(
                      text: "Contraseña",
                      controller: password,
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
                  mostrarAlertaCargando(context, "Actualizando Información...");

                  String encryptedPasswordActual =
                      Usuario.encryptPassword(password.text);

                  DocumentSnapshot documentSnapshot = await FirebaseFirestore
                      .instance
                      .collection('users')
                      .doc(controllerUser.user!.userId == ""
                          ? ""
                          : controllerUser.user!.userId)
                      .get();

                  if (documentSnapshot.exists) {
                    Map<String, dynamic>? userData =
                        documentSnapshot.data() as Map<String, dynamic>?;

                    Usuario user = Usuario.fromJson(userData!);

                    if (encryptedPasswordActual == user.password) {
                      if (widget.image != null) {
                        Navigator.of(context).pop();
                        mostrarAlertaCargando(context, "Subiendo Imagen...");

                        Reference ref = FirebaseStorage.instance
                            .ref()
                            .child('users')
                            .child(user.userId)
                            .child('profile.jpg');

                        UploadTask uploadTask = ref.putFile(widget.image!);
                        await uploadTask.whenComplete(() => null);
                      }

                      Navigator.of(context).pop();
                      mostrarAlertaCargando(
                          context, "Subiendo Nombre y Correo...");

                      try {
                        if (user.correo == widget.correo) {
                          await FirebaseFirestore.instance
                              .collection('users')
                              .doc(controllerUser.user!.userId)
                              .update({
                            'nombre': widget.nombre,
                            'correo': widget.correo,
                          });
                        } else {
                          QuerySnapshot existingEmail = await FirebaseFirestore
                              .instance
                              .collection('users')
                              .where('correo', isEqualTo: widget.correo)
                              .get();

                          if (existingEmail.docs.isNotEmpty) {
                            Navigator.of(context).pop();
                            mostrarAlertaError(
                                context, "El correo ya está en uso.");
                            return;
                          } else {
                            await FirebaseFirestore.instance
                                .collection('users')
                                .doc(controllerUser.user!.userId)
                                .update({
                              'nombre': widget.nombre,
                              'correo': widget.correo,
                            });
                          }
                        }

                        Usuario userCont = controllerUser.user!;

                        userCont.correo = widget.correo;
                        userCont.nombre = widget.nombre;

                        Map<dynamic, dynamic> currentUserData =
                            _authBox?.getAt(0);
                        currentUserData['nombre'] = widget.nombre;
                        currentUserData['correo'] = widget.correo;

                        _authBox?.putAt(0, currentUserData);

                        Navigator.of(context).pop();
                        mostrarAlertaSucces(
                            context, "Información actualizada exitosamente",
                            () {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const Home(
                                index: 3,
                              ),
                            ),
                            (Route<dynamic> route) => false,
                          );
                        });
                      } catch (e) {
                        Navigator.of(context).pop();
                        mostrarAlertaError(
                          context,
                          "Error al actualizar la información: $e",
                        );
                      }
                    } else {
                      Navigator.of(context).pop();
                      mostrarAlertaError(
                          context, "Contraseña actual incorrecta.");
                    }
                  } else {
                    Navigator.of(context).pop();
                    mostrarAlertaError(
                        context, "Presentamos problemas. Intenta más tarde.");
                  }
                },
                bg: primaryColor(),
                textColor: colorWhite(),
                text: "Validar Contraseña",
              ),
            ),
          ],
        ),
      ),
    );
  }
}
