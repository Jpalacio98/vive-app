import 'dart:math';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:vive_app/domain/services/local_notifications.dart';

part 'notifications_event.dart';
part 'notifications_state.dart';

Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  var mensaje = message.data;
  var title = mensaje['title'];
  var body = mensaje['body'];
  Random random = Random();
  var id = random.nextInt(100000);
  LocalNotification.showLocalNotification(id: id, title: title, body: body);
}

class NotificationsBloc extends Bloc<NotificationsEvent, NotificationsState> {
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  final String apiUrl = dotenv.env['API_URL']!;
  NotificationsBloc() : super(NotificationsInitial()) {
    _onForegroundMessage();
  }

  void requestPermission() async {
    NotificationSettings settings = await messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: true,
        provisional: false,
        sound: true);

    await LocalNotification.requestPermissionLocalNotifications();
    settings.authorizationStatus;
    getToken();
  }

  Future<String> getToken() async {
    final settings = await messaging.getNotificationSettings();
    if (settings.authorizationStatus != AuthorizationStatus.authorized)
      return 'null';

    final token = await messaging.getToken();
    if (token != null) {
      // final prefs = PreferenciasUsuario();
      // prefs.token = token;
      print("Token id: $token");
      return token;
    }
    return 'null';
  }

  void _onForegroundMessage() {
    FirebaseMessaging.onMessage.listen(handleRemoteMessage);
  }

  void handleRemoteMessage(RemoteMessage message) {
    var mensaje = message.data;
    var title = mensaje['title'];
    var body = mensaje['body'];

    Random random = Random();
    var id = random.nextInt(100000);

    LocalNotification.showLocalNotification(id: id, title: title, body: body);
  }

  Future<void> createGroup(String name, List<String> members) async {
    // Asegúrate de que la variable esté definida

    final response = await http.post(
      Uri.parse('$apiUrl/subscribe'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'topicName': name,
        'tokens': members,
      }),
    );

    if (response.statusCode == 200) {
      // Procesar la respuesta
      final responseData = jsonDecode(response.body);
      print('Éxito: ${responseData}');
    } else {
      // Manejar el error
      print('Error en la suscripción: ${response.statusCode}');
    }
  }

  Future<void> sendNotificationToTopic(
      String topic, String title, String message) async {
    final response = await http.post(
      Uri.parse('$apiUrl/topic/send_notification'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'topic': topic,
        'titulo': title,
        'mensaje': message,
      }),
    );

    if (response.statusCode == 200) {
      // Procesar la respuesta
      final responseData = jsonDecode(response.body);
      print('Notificación enviada: ${responseData}');
    } else {
      // Manejar el error
      print('Error al enviar la notificación: ${response.statusCode}');
    }
  }
}
