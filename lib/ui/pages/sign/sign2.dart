// ignore_for_file: must_be_immutable

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:vive_app/domain/services/respuestaSign.dart';
import 'package:vive_app/ui/components/btnCustom.dart';
import 'package:vive_app/ui/components/customProgresoSign.dart';
import 'package:vive_app/ui/components/customTextfield1.dart';
import 'package:vive_app/utils/styles.dart';

class Sign2 extends StatefulWidget {
  late String code;
  final String correo;
  Sign2({super.key, required this.code, required this.correo});

  @override
  State<Sign2> createState() => _Sign2State();
}

class _Sign2State extends State<Sign2> {
  final TextEditingController codeController = TextEditingController();
  Timer? _timer;
  int _start = 60;

  void _startTimer() {
    setState(() {
      _start = 60;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_start > 0) {
          _start--;
        } else {
          _timer?.cancel();
        }
      });
    });
  }

  void _resendCode() async {
    String newCode = await RespuestaSign.reenviarCodigo(widget.correo, context);
    widget.code = newCode.isNotEmpty ? newCode : widget.code;
    _startTimer();
  }

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    codeController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Paso 2 de 4",
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ProgresoSign(porcentaje: fullWidth(context) * 0.48),
                    const SizedBox(height: 20),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        "Confirma el código",
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
                        "Hemos enviado un código a tu correo.",
                        style: TextStyle(
                            fontSize: 17,
                            color: Colors.black87,
                            fontWeight: FontWeight.w400),
                      ),
                    ),
                    const SizedBox(height: 20),
                    CustomTextField1(
                      text: "Código de verificación",
                      controller: codeController,
                      keyboardType: "number",
                    ),
                    const SizedBox(height: 20),
                    Align(
                      alignment: Alignment.center,
                      child: TextButton(
                        onPressed: _start == 0 ? _resendCode : null,
                        child: Text(
                          _start == 0
                              ? "Reenviar código"
                              : "Reenviar código en $_start s",
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: BtnCustom(
                onPressed: () {
                  RespuestaSign.verificarCodigo(
                      code: widget.code,
                      codeEscrito: codeController.text,
                      correo: widget.correo,
                      context: context);
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
