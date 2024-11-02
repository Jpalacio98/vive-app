import 'package:flutter/material.dart';
import 'package:vive_app/domain/services/respuestaSign.dart';
import 'package:vive_app/ui/components/customTextfield1.dart';
import 'package:vive_app/ui/pages/passwordChagen.dart';
import 'package:vive_app/utils/styles.dart';

class EnviarCodigo extends StatefulWidget {
  const EnviarCodigo({super.key});

  @override
  State<EnviarCodigo> createState() => _EnviarCodigoState();
}

class _EnviarCodigoState extends State<EnviarCodigo> {
  TextEditingController correo = TextEditingController();

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
                      "Enviaremos un código a tu correo electronico.",
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
                      "Correo",
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(height: 20),
                  CustomTextField1(
                    text: "Correo",
                    controller: correo,
                  ),
                  const SizedBox(height: 20),
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
                  String email = correo.text.trim();

                  String newCode =
                      await RespuestaSign.reenviarCodigo(email, context);

                  if (newCode != "") {
                    Navigator.of(context).pop();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ChagenPassword(code: newCode, correo: email,)),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor(),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                child: const Text(
                  "Siguiente",
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
