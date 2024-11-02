import 'package:flutter/material.dart';
import 'package:vive_app/domain/services/respuestaSign.dart';
import 'package:vive_app/ui/components/btnCustom.dart';
import 'package:vive_app/ui/components/customProgresoSign.dart';
import 'package:vive_app/ui/components/customTextfield1.dart';
import 'package:vive_app/utils/styles.dart';

class Sign1 extends StatefulWidget {
  const Sign1({super.key});

  @override
  State<Sign1> createState() => _Sign1State();
}

class _Sign1State extends State<Sign1> {
  final TextEditingController controllerCorreo = TextEditingController();

  @override
  void dispose() {
    controllerCorreo.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Paso 1 de 4",
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
        centerTitle: true,
      ),
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ProgresoSign(
                      porcentaje: fullWidth(context) * 0.24,
                    ),
                    const SizedBox(height: 20),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        "Empecemos a crear tu cuenta",
                        style: TextStyle(
                            fontSize: 35,
                            color: Colors.black87,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        "Enviaremos un código a tu correo para verificar que este correo te pertenece",
                        style: TextStyle(
                            fontSize: 17,
                            color: Colors.black87,
                            fontWeight: FontWeight.w400),
                      ),
                    ),
                    const SizedBox(height: 20),
                    CustomTextField1(
                      text: "Correo",
                      controller: controllerCorreo,
                    ),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: BtnCustom(
                onPressed: () async {
                  RespuestaSign.enviarCodigo(controllerCorreo.text, context);
                },
                bg: primaryColor(),
                textColor: colorWhite(),
                text: "Siguiente",
              ),
            ),
          ],
        ),
      ),
    );
  }
}
