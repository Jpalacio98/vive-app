import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:vive_app/domain/models/user.dart';
import 'package:vive_app/infrastructure/controllers/controllerUser.dart';
import 'package:vive_app/infrastructure/controllers/map.dart';
import 'package:vive_app/ui/pages/home.dart';
import 'package:vive_app/utils/styles.dart';

class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  _SplashState createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  Box? _authBox;
  Usuario? _user;
  static final MapController controller = Get.find();

  @override
  void initState() {
    super.initState();
    
    controller.getCurrentLocation();
    _authBox = Hive.box('auth');
    Future.delayed(const Duration(seconds: 5), () {
      if (_authBox?.isNotEmpty ?? false) {
        var userData = _authBox?.getAt(0);

        if (userData != null) {
          _user = Usuario.fromMap(userData);
        }
      }

      if (_user != null) {
        final ControllerUser controlleruser = Get.find();
        controlleruser.DataUser(_user!);
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => const Home(),
          ),
          (Route<dynamic> route) => false,
        );
      } else {
        Navigator.pushReplacementNamed(context, '/init_page');
      }
    });
  }
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: bgPrincipal(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: Image.asset(
                "assets/logo-vive.png",
                width: 90,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
