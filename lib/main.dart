import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:vive_app/app/myApp.dart';
import 'package:vive_app/config/firebase_options.dart';
import 'package:vive_app/domain/services/bloc/notifications_bloc.dart';
import 'package:vive_app/domain/services/local_notifications.dart';
import 'package:vive_app/infrastructure/controllers/controllerUser.dart';
import 'package:vive_app/infrastructure/controllers/map.dart';

//import 'package:vive_app/ui/pages/limpiarCache.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  await LocalNotification.initializeLocalNotifications();
  
  await Hive.initFlutter();
  // limpiarBaseDeDatos();
  await Hive.openBox('grupos');
  await Hive.openBox('mensajes');
  await Hive.openBox('auth');
  await Hive.openBox('miembros');
  await Hive.openBox('ultimoMensaje');

  Get.put(ControllerUser());
  Get.put(MapController());
  await dotenv.load(fileName:".env");
  runApp(MultiBlocProvider(
    providers: [
      BlocProvider(
        create: (context) => NotificationsBloc(),
      ),
    ],
    child: const MyApp(),
  ));
}
