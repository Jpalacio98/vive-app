import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:vive_app/domain/alerts/alertCargando.dart';
import 'package:vive_app/domain/models/user.dart';
import 'package:vive_app/infrastructure/controllers/controllerUser.dart';
import 'package:vive_app/ui/pages/cuenta.dart';
import 'package:vive_app/ui/pages/login.dart';
import 'package:vive_app/ui/pages/privacidad.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Box? _authBox;

  @override
  void initState() {
    super.initState();
    _authBox = Hive.box('auth');
  }

  @override
  Widget build(BuildContext context) {
    final ControllerUser controllerUser = Get.find();

    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding:
            const EdgeInsets.only(top: 100, right: 20, bottom: 20, left: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Obx(() => Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                        color:
                            const Color.fromARGB(52, 177, 207, 231).withOpacity(0.5),
                        width: 4), // Borde azul suave
                  ),
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: NetworkImage('${controllerUser.user!.imageUrl}?${DateTime.now().millisecondsSinceEpoch}'),

                  ),
                )),
            const SizedBox(height: 16),
            const Text(
              "Correo",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Obx(() => Text( 
                  controllerUser.user!.correo,
                  style: const TextStyle(fontSize: 16),
                )),
            const SizedBox(height: 24),
            const Text("Ajustes", style: TextStyle(fontSize: 18)),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Configuración de la cuenta'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const Cuenta(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.lock),
              title: const Text('Privacidad'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const Privacidad(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Cerrar sesión'),
              onTap: () async {
                mostrarAlertaCargando(context, "Cerrando Sesión...");

                await Future.delayed(const Duration(seconds: 2), () async {
                  if (_authBox?.isNotEmpty ?? false) {
                    await _authBox?.deleteAt(0);
                  }
                  
                  Usuario usuario = Usuario(
                      correo: "", 
                      nombre: "",
                      imageUrl: "",
                      password: "",
                      userId: "");
                  Navigator.of(context).pop();

                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
                    (Route<dynamic> route) => false,
                  );

                  controllerUser.DataUser(usuario);

                  
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
