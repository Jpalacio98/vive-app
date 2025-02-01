
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// Servicio de pagos
class PaymentService {
  static String apiKey = dotenv.env['STRIPE_KEY']!;
  static String backendUrl = "${dotenv.env['API_URL']!}/process-payment'";

  static Future<void> initialize() async {
    Stripe.publishableKey = apiKey;
    await Stripe.instance.applySettings();
  }

  static Future<bool> processPayment(String token, double amount) async {
    try {
      final response = await http.post(
        Uri.parse(backendUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'token': token,
          'amount': (amount * 100).toInt(), // Convertir a centavos
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error al procesar pago: $e');
      rethrow; // Relanzar el error para manejarlo en la UI
    }
  }
}
