import 'package:flutter/material.dart';
import 'package:vive_app/ui/components/btnCustom.dart';
import 'package:vive_app/utils/styles.dart';

class ErrorView extends StatefulWidget {
  final String errorMessage;
  final VoidCallback onRetry;

  const ErrorView({
    super.key,
    required this.errorMessage,
    required this.onRetry,
  });

  @override
  _ErrorViewState createState() => _ErrorViewState();
}

class _ErrorViewState extends State<ErrorView>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..forward();

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: FadeTransition(
        opacity: _animation,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Ícono de error
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.redAccent.withOpacity(0.1),
                ),
                child: const Icon(
                  Icons.error_outline,
                  size: 50,
                  color: Colors.redAccent,
                ),
              ),
              const SizedBox(height: 20),
              // Mensaje de error
              Text(
                widget.errorMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 20,
                  color: Color.fromARGB(255, 0, 0, 0),
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              // Botón para intentar de nuevo
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: BtnCustom(
                  onPressed: widget.onRetry,
                  bg: primaryColor(),
                  textColor: colorWhite(),
                  text: "Volver a Inicio",
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
