
//import 'package:vive_app/ui/pages/limpiarCache.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:vive_app/app/myApp.dart';
import 'package:vive_app/config/firebase_options.dart';
import 'package:vive_app/domain/services/bloc/notifications_bloc.dart';
import 'package:vive_app/domain/services/local_notifications.dart';
import 'package:vive_app/infrastructure/controllers/controllerUser.dart';
import 'package:vive_app/infrastructure/controllers/map.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  await LocalNotification.initializeLocalNotifications();
  print(
      "-------------------------test de petecion--------------------------------");
  // print("url del server: ${dotenv.env['API_URL']!}");
  // final notify = NotificationsBloc();
  // String m1 = "e04zDhXKSTqcNbEqz8yduS:APA91bE77jJvt6fIYewJFelpVo_DpKkMaQE28Oskgw0acrubh9nlzzgWYWmiI94Qs-FQYMqicQOKDqURTukJ5lTg_LAWUKoXhLx54-wCIVMqTERpszC5Am8";
  // String m2 = "miembro2";
  // List<String> members = [];
  // members.add(m1);
  // print(members);
  // await notify.createGroup("los chisco del barrio", members);
  print(
      "-------------------------------------------------------------------------");
  await Geolocator.requestPermission();
  await Hive.initFlutter();
  //limpiarBaseDeDatos();
  await Hive.openBox('grupos');
  await Hive.openBox('mensajes');
  await Hive.openBox('auth');
  await Hive.openBox('miembros');
  await Hive.openBox('ultimoMensaje');

  Get.put(ControllerUser());
  Get.put(MapController());

  print(dotenv.env['API_URL']!);
  runApp(MultiBlocProvider(
    providers: [
      BlocProvider(
        create: (context) => NotificationsBloc(),
      ),
    ],
    child: const MyApp(),
  ));
}
