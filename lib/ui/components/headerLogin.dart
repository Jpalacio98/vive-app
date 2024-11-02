import 'package:flutter/material.dart';
import 'package:vive_app/ui/pages/init.dart';
import 'package:vive_app/utils/styles.dart';

class HeaderLogin extends StatelessWidget {
  const HeaderLogin({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: fullWidth(context),
      height: 220,
      child: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            bottom: 0,
            child: CustomPaint(
              painter: MyHeaderPainter(),
            ),
          ),
          Positioned(
            top: 50,
            right: 30,
            child: Image.asset(
              'assets/logo-vive.png',
              width: 120,
              height: 120,
              fit: BoxFit.contain,
            ),
          ),
          Positioned(
              top: 40,
              child: IconButton(
                onPressed: () {
                   Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const InitPage()),
                    );

                },
                icon: Icon(
                  Icons.arrow_back,
                  color: colorWhite(),
                  size: 30,
                ),
              ))
        ],
      ),
    );
  }
}

class MyHeaderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = bgPrincipal()
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.butt
      ..style = PaintingStyle.fill;

    final path = Path();

    path.moveTo(0, 0);

    path.lineTo(0, 150);

    path.lineTo(size.width, size.height);

    path.lineTo(size.width, 0);

    path.lineTo(0, 0);

    canvas.drawShadow(path, const Color.fromARGB(113, 201, 201, 201), 5.0, true);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(MyHeaderPainter oldDelegate) => true;
}
