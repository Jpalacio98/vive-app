import 'dart:io';
import 'package:flutter/material.dart';
import 'package:vive_app/infrastructure/repository/userService.dart';

class LoadingAccountCreation extends StatefulWidget {
  final String correo;
  final File image;
  final String nombre;
  final String password;
  final String token;

  const LoadingAccountCreation({
    super.key,
    required this.correo,
    required this.image,
    required this.nombre,
    required this.password,
    required this.token,
  });

  @override
  _LoadingAccountCreationState createState() => _LoadingAccountCreationState();
}

class _LoadingAccountCreationState extends State<LoadingAccountCreation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 1.0, end: 1.5).animate(_controller);

    //subir al firebase
    UserService.registerUser(
        context: context,
        correo: widget.correo,
        password: widget.password,
        nombre: widget.nombre,
        image: widget.image,token: widget.token,);
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
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return Container(
                  width: 100 * _animation.value,
                  height: 100 * _animation.value,
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(50),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            const Text(
              'Creando tu cuenta...',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
