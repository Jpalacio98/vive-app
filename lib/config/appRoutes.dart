import 'package:flutter/material.dart';
import 'package:vive_app/app/splash.dart';
import 'package:vive_app/ui/pages/init.dart';
import 'package:vive_app/ui/pages/login.dart';
import 'package:vive_app/ui/pages/sign/sign1.dart';

class AppRoutes {
  static const String splash = '/';
  static const String initPage = '/init_page';
  static const String loginScreen = '/login_screen';
  static const String createAccount = '/create-account';
  static const String home = '/home';
  static const String sign1 = '/sign1';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const Splash());
      case initPage:
        return MaterialPageRoute(builder: (_) => const InitPage());
      case loginScreen:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case sign1:
        return MaterialPageRoute(builder: (_) => const Sign1());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }
}
