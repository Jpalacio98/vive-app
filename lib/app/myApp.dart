import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:vive_app/config/appRoutes.dart';
import 'package:vive_app/domain/models/grupos.dart';
import 'package:vive_app/domain/services/bloc/notifications_bloc.dart';
import 'package:vive_app/ui/pages/chat.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  

  @override
  Widget build(BuildContext context) {
    context.read<NotificationsBloc>().requestPermission();
    _obtenerUbicacion();
    return GetMaterialApp(
      title: 'vive_app',
      initialRoute: AppRoutes.splash,
      routes: {
        '/chat': (context) =>
            Chat(grupo: ModalRoute.of(context)!.settings.arguments as Grupos),
      },
      onGenerateRoute: AppRoutes.generateRoute,
      debugShowCheckedModeBanner: false,
    );
  }
  Future<Position> _obtenerUbicacion() async {
    LocationPermission permiso = await Geolocator.checkPermission();
    if (permiso == LocationPermission.denied) {
      permiso = await Geolocator.requestPermission();
      if (permiso == LocationPermission.denied) {
        throw Exception('Los permisos de ubicación están denegados');
      }
    }
    return await Geolocator.getCurrentPosition(
        // ignore: deprecated_member_use
        desiredAccuracy: LocationAccuracy.high);
  }
}
