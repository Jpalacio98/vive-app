// ignore_for_file: unused_result

import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_stripe/flutter_stripe.dart';


class DonationsPage extends StatefulWidget {
  // ✅ Cambiar a StatefulWidget
  @override
  _DonationsPageState createState() => _DonationsPageState();
}

class _DonationsPageState extends State<DonationsPage>
    with SingleTickerProviderStateMixin {
  late ScrollController _scrollController;
  final GlobalKey _formKeyPage = GlobalKey();
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  bool _showForm = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1), // Posición inicial: abajo del todo
      end: Offset.zero, // Posición final: en su lugar
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  void _toggleForm() {
    setState(() {
      _showForm = !_showForm;
      if (_showForm) {
        _animationController.forward().then((_) {
          // Scroll al formulario después de la animación
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Scrollable.ensureVisible(
              _formKeyPage.currentContext!,
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
            );
          });
        });
      } else {
        _animationController.reverse().then((_) {
          // Scroll al top al cerrar
          _scrollController.animateTo(
            0,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        });
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Donaciones"),
        centerTitle: true,
        backgroundColor: const Color(0xFFA1D0FF),
      ),
      body: SingleChildScrollView(
        // ✅ Scroll general
        controller: _scrollController,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(
                Icons.volunteer_activism,
                size: 80,
                color: Color(0xFFA1D0FF),
              ),
              const SizedBox(height: 16),
              const Text(
                "Haz una diferencia con tu donación",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFA1D0FF),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                "Tu contribución ayuda a apoyar nuestras causas y mejorar la vida de muchas personas. Cualquier cantidad es valiosa.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
              ),
              const SizedBox(height: 150),
              ElevatedButton.icon(
                onPressed: _toggleForm, // ✅ Usar el nuevo método
                icon: const Icon(
                  Icons.favorite,
                  color: Colors.white,
                ),
                label: Text(
                  _showForm ? "Ocultar formulario" : "Donar ahora",
                  style: const TextStyle(fontSize: 18, color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFA1D0FF),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  textStyle: const TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
              const SizedBox(height: 120),

              // ✅ Sección animada del formulario
              AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, (1 - _animationController.value) * 100),
                    child: Opacity(
                      opacity: _animationController.value,
                      child: child,
                    ),
                  );
                },
                child: DonationForm(
                  key: _formKeyPage,
                  onCancel: _toggleForm,
                ),
              ),
              const SizedBox(height: 120),
            ],
          ),
        ),
      ),
    );
  }
}

class DonationForm extends StatefulWidget {
  final VoidCallback onCancel;

  const DonationForm({required this.onCancel, super.key});

  @override
  State<DonationForm> createState() => _DonationFormState();
}

class _DonationFormState extends State<DonationForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _amountController = TextEditingController();
  final _cardNumberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();
  bool _isLoading = false;
  final String apiUrl = dotenv.env['API_URL']!;
  String? _customerId;

  void loadCard() async {
    try {
      final expiryParts = _expiryController.text.split('/');
      CardDetails _card = CardDetails(
        number: _cardNumberController.text.replaceAll(' ', ''),
        expirationMonth: int.parse(expiryParts[0]),
        expirationYear: int.parse(expiryParts[1]),
        cvc: _cvvController.text);

      await Stripe.instance.dangerouslyUpdateCardDetails(_card);
    } catch (e) {
      ErrorSnackBar.show(context, e.toString());
    }
    
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _amountController.dispose();
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  Future<void> _donate() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      
      // 1. Validar datos de la tarjeta
      loadCard();
      // 2. Crear PaymentMethod usando los datos de la tarjeta
      final paymentMethod = await Stripe.instance.createPaymentMethod(
        params: PaymentMethodParams.card(
          paymentMethodData: PaymentMethodData(
            billingDetails: BillingDetails(
              name: _nameController.text,
              email: _emailController.text,
            ),
          ),
        ),
      );

       // 3. Crear PaymentIntent en el backend (Flask)
      final amount = (double.parse(_amountController.text) * 100).toInt();
      final response = await http.post(
        Uri.parse('$apiUrl/crear-payment-intent'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'amount': amount, 'currency': 'mxn'}),
      );

      final payment_intent = jsonDecode(response.body);
      print(payment_intent['client_secret']);
      // 4. Confirmar el pago con el PaymentMethod
      await Stripe.instance.confirmPayment(
        paymentIntentClientSecret: payment_intent['client_secret'],
        data: PaymentMethodParams.card(
          paymentMethodData: PaymentMethodData(
            billingDetails: BillingDetails(
              email: paymentMethod.billingDetails.email,
              name: paymentMethod.billingDetails.name,
            )
          ), // Adjuntar el PaymentMethod
        ),
      );

      final response2 = await http.post(
        Uri.parse('$apiUrl/donate'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name':_nameController.text,
          'email':_emailController.text,
          'amount': _amountController.text,
          'payment_intent': payment_intent}),
      );
      print(response2.body);
      cleanForm();
      widget.onCancel();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(
                Icons.volunteer_activism_rounded,
                color: Colors.white,
                size: 50,
              ),
              SizedBox(
                width: 20,
              ),
              Text(
                '¡Donación exitosa!',
                style: TextStyle(fontSize: 25, color: Colors.white),
              ),
            ],
          ),
          backgroundColor: Color(0xFFA1D0FF),
        ),
      );
    } catch (e) {
      ErrorSnackBar.show(context, e.toString());
    }
  }

  void cleanForm() {
    _nameController.clear();
    _emailController.clear();
    _amountController.clear();
    _cardNumberController.clear();
    _expiryController.clear();
    _cvvController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      decoration: BoxDecoration(
        color: Colors.white30,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          inputDecorationTheme: const InputDecorationTheme(
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Color(0xFFA1D0FF), width: 1.5),
              ),
              focusColor: Color(0xFFA1D0FF),

              // labelStyle: TextStyle(
              //   color: Colors.grey.shade700
              // ),
              floatingLabelStyle: TextStyle(color: Color(0xFFA1D0FF))),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                _buildFormHeader(),
                const SizedBox(height: 20),
                _buildNameField(),
                const SizedBox(height: 15),
                _buildEmailField(),
                const SizedBox(height: 15),
                _buildAmountField(),
                const SizedBox(height: 15),
                _buildCardNumberField(),
                const SizedBox(height: 15),
                _buildExpiryAndCvvFields(),
                const SizedBox(height: 30),
                _buildActionButtons(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          "Datos de Donación",
          style: TextStyle(
            fontSize: 20,
            color: Color(0xFFA1D0FF),
            fontWeight: FontWeight.bold,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.close),
          onPressed: widget.onCancel,
        ),
      ],
    );
  }

  Widget _buildNameField() {
    return TextFormField(
      controller: _nameController,
      decoration: const InputDecoration(
        labelText: "Nombre Completo",
        prefixIcon: Icon(
          Icons.person,
          color: Color(0xFFA1D0FF),
        ),
        border: OutlineInputBorder(),
      ),
      validator: (value) => value!.isEmpty ? "Campo requerido" : null,
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      decoration: const InputDecoration(
        labelText: "Correo Electrónico",
        prefixIcon: Icon(
          Icons.email,
          color: Color(0xFFA1D0FF),
        ),
        border: OutlineInputBorder(),
      ),
      validator: (value) => !value!.contains('@') ? "Correo inválido" : null,
    );
  }

  Widget _buildAmountField() {
    return TextFormField(
      controller: _amountController,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
      ],
      decoration: const InputDecoration(
        labelText: "Monto (\$)",
        prefixIcon: Icon(
          Icons.attach_money,
          color: Color(0xFFA1D0FF),
        ),
        border: OutlineInputBorder(),
      ),
      validator: (value) => value!.isEmpty ? "Ingrese un monto" : null,
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
              onPressed: widget.onCancel,
              style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  side: const BorderSide(color: Color(0xFFA1D0FF)),
                  textStyle: const TextStyle(color: Color(0xFFA1D0FF))),
              child: const Text(
                "Cancelar",
                style: TextStyle(color: Color(0xFFA1D0FF)),
              )),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: ElevatedButton(
            onPressed: _isLoading ? null : _donate,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 15),
              backgroundColor: const Color(0xFFA1D0FF),
            ),
            child: _isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text(
                    "Continuar al Pago",
                    style: TextStyle(color: Colors.white),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildCardNumberField() {
    return TextFormField(
      controller: _cardNumberController,
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(19),
        _CardNumberFormatter(),
      ],
      decoration: const InputDecoration(
        labelText: "Número de Tarjeta",
        prefixIcon: Icon(
          Icons.credit_card,
          color: Color(0xFFA1D0FF),
        ),
        border: OutlineInputBorder(),
        hintText: "XXXX XXXX XXXX XXXX",
      ),
      validator: (value) {
        final cleaned = value!.replaceAll(' ', '');
        if (cleaned.length != 16) return "Tarjeta inválida";
        return null;
      },
    );
  }

  Widget _buildExpiryAndCvvFields() {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            controller: _expiryController,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(4),
              _ExpiryFormatter(),
            ],
            decoration: const InputDecoration(
              labelText: "MM/AA",
              border: OutlineInputBorder(),
              hintText: "MM/YY",
            ),
            validator: (value) {
              if (value!.length != 5) return "Fecha inválida";
              final parts = value.split('/');
              if (parts.length != 2) return "Formato MM/AA";
              final month = int.tryParse(parts[0]);
              final year = int.tryParse(parts[1]);
              if (month == null || year == null) return "Valores inválidos";
              if (month < 1 || month > 12) return "Mes inválido";
              return null;
            },
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: TextFormField(
            controller: _cvvController,
            keyboardType: TextInputType.number,
            obscureText: true,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(4),
            ],
            decoration: const InputDecoration(
              labelText: "CVV",
              border: OutlineInputBorder(),
              hintText: "XXX",
            ),
            validator: (value) {
              if (value!.length < 3 || value.length > 4) return "CVV inválido";
              return null;
            },
          ),
        ),
      ],
    );
  }
}

class _CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll(' ', '');
    var formatted = '';
    for (int i = 0; i < text.length; i++) {
      if (i % 4 == 0 && i != 0) formatted += ' ';
      formatted += text[i];
    }
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

class _ExpiryFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll('/', '');
    var formatted = '';
    for (int i = 0; i < text.length; i++) {
      if (i == 2) formatted += '/';
      formatted += text[i];
    }
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}





class ErrorSnackBar extends StatelessWidget {
  final String errorMessage;

  const ErrorSnackBar({super.key, required this.errorMessage});

  static void show(BuildContext context, String error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFFA1D0FF),
        content: ErrorSnackBar(errorMessage: error),
      ),
    );
  }

  List<Widget> _buildErrorMessages() {
    final parts = errorMessage.split(':');
    int indentLevel = 0;

    return parts.map((part) {
      final trimmedPart = part.trim();
      if (trimmedPart.isEmpty) return const SizedBox.shrink();

      final widget = Padding(
        padding: EdgeInsets.only(left: indentLevel * 20.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Flexible(
              child: Text(
                trimmedPart,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                ),
                textAlign: TextAlign.left,
              ),
            ),
          ],
        ),
      );

      indentLevel++;
      return widget;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_outlined,
              color: Colors.white,
              size: 20,
            ),
            SizedBox(width: 10),
            Text(
              'ERROR',
              style: TextStyle(fontSize: 14, color: Colors.white),
            ),
            SizedBox(width: 10),
            Icon(
              Icons.error_outline_outlined,
              color: Colors.white,
              size: 20,
            )
          ],
        ),
        const SizedBox(height: 10),
        ..._buildErrorMessages(),
      ],
    );
  }
}