
import 'package:flutter/material.dart';

class MyHeaderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF0059d4)
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.butt
      ..style = PaintingStyle.fill;

    final path = Path();

    path.moveTo(size.width, 0);

    path.lineTo(size.width * 0.2, 0);

    path.lineTo(size.width * 0.2 + 10, 20);

    path.arcToPoint(
      Offset(size.width * 0.6, 120),
      radius: const Radius.circular(150),
      clockwise: false,
    );

    path.arcToPoint(
      Offset(size.width * 0.75, 300),
      radius: const Radius.circular(100),
      clockwise: true,
    );

    path.arcToPoint(
      Offset(size.width * 0.3, 250),
      radius: const Radius.circular(110),
      clockwise: true,
    );

    path.arcToPoint(
      Offset(size.width * 0, 300),
      radius: const Radius.circular(50),
      clockwise: false,
    );

    path.lineTo(size.width * 0, 400);

    path.arcToPoint(
      Offset(size.width * 0.5, 450),
      radius: const Radius.circular(170),
      clockwise: true,
    );

    path.arcToPoint(
      Offset(size.width, 450),
      radius: const Radius.circular(140),
      clockwise: false,
    );

    path.lineTo(size.width, 0);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(MyHeaderPainter oldDelegate) => true;
}
