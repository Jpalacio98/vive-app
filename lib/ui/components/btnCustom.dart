import 'package:flutter/material.dart';
import 'package:vive_app/utils/styles.dart';

class BtnCustom extends StatelessWidget {
  final String text;
  final Color bg;
  final Color textColor;
  final VoidCallback onPressed;
  final Color borderColor; // Color del borde
  final double borderWidth; // Grosor del borde

  const BtnCustom({
    super.key,
    required this.text,
    required this.bg,
    required this.textColor,
    required this.onPressed,
    this.borderColor = Colors.blue, // Color por defecto para el borde
    this.borderWidth = 1.0, // Grosor por defecto para el borde
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: marginBtn(),
      width: 400,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: bg, // Color de fondo
          padding: paddingBtn(),
          side: BorderSide(
            color: borderColor, // Color del borde
            width: borderWidth, // Grosor del borde
          ),
        ),
        child: Text(
          text,
          style: TextStyle(color: textColor, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}
