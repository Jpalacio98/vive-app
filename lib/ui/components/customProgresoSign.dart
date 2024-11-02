
import 'package:flutter/material.dart';
import 'package:vive_app/utils/styles.dart';

class ProgresoSign extends StatelessWidget {
  final double porcentaje;
  const ProgresoSign({super.key, required this.porcentaje});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: fullWidth(context),
      color: const Color.fromARGB(255, 224, 227, 230),
      height: 4,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            color: primaryColor(),
            width: porcentaje,
          ),
        ],
      ),
    );
  }
}