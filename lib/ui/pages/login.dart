import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:hive/hive.dart';

import 'package:vive_app/domain/models/user.dart';
import 'package:vive_app/domain/services/bloc/notifications_bloc.dart';
import 'package:vive_app/infrastructure/repository/userService.dart';
import 'package:vive_app/ui/components/btnCustom.dart';
import 'package:vive_app/ui/components/checkCustom.dart';
import 'package:vive_app/ui/components/customTextfield.dart';
import 'package:vive_app/ui/components/headerLogin.dart';
import 'package:vive_app/ui/pages/EnviarCodigo.dart';
import 'package:vive_app/ui/pages/sign/sign1.dart';
import 'package:vive_app/utils/styles.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController correoController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  Box? _authBox;
  bool _isChecked = false;
  late String tokenCurrentDevice;

  @override
  void initState() {
    super.initState();
    _authBox = Hive.box('auth');
  }
   

  @override
  Widget build(BuildContext context) {
    context.read<NotificationsBloc>().requestPermission();
    getToken(context);
    return Scaffold(
      body: Container(
        color: bg(),
        width: fullWidth(context),
        height: fullHeight(context),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const HeaderLogin(),
              SizedBox(
                height: fullHeight(context) * 0.05,
              ),
              CustomTextField(
                controller: correoController,
                icon: Icons.person,
                text: "Nombre de usuario",
                isPassword: false,
              ),
              const SizedBox(
                height: 5,
              ),
              CustomTextField(
                controller: passwordController,
                icon: Icons.lock,
                text: "Contraseña",
                isPassword: true,
              ),
              CustomCheckRow(
                isChecked: _isChecked,
                onChanged: (bool value) {
                  setState(() {
                    _isChecked = value; 
                  });
                },
              ),
              const SizedBox(
                height: 10,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: BtnCustom(
                  onPressed: () {
                    
                    String correo = correoController.text.trim();
                    String password = passwordController.text.trim();
                    password = Usuario.encryptPassword(password);

                    UserService.login(correo, password, context, _isChecked, _authBox,tokenCurrentDevice);
                  },
                  bg: primaryColor(),
                  textColor: colorWhite(),
                  text: "Iniciar Sesión",
                ),
              ),
              SizedBox(
                height: fullHeight(context) * 0.05,
              ),
              TextButton(
                  onPressed: () {

                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const EnviarCodigo()),
                    );
                    
                  },
                  child: const Text(
                    "¿Haz olvidado tu contraseña?",
                    style: TextStyle(
                        fontWeight: FontWeight.w600, color: Colors.black),
                  )),
              SizedBox(
                height: fullHeight(context) * 0.05,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: BtnCustom(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const Sign1()),
                    );
                  },
                  bg: colorWhite(),
                  borderColor: primaryColor(),
                  textColor: primaryColor(),
                  text: "Crear Cuenta",
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> getToken(BuildContext context) async {
    tokenCurrentDevice = await context.read<NotificationsBloc>().getToken();
    
  }
  
}
