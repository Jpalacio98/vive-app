import 'package:flutter/material.dart';
import 'package:vive_app/utils/styles.dart';

class CustomTextField1 extends StatefulWidget {
  final bool isPassword;
  final String text;
  final TextEditingController controller;

  const CustomTextField1({
    super.key,
    this.isPassword = false,
    required this.text,
    required this.controller,
  });

  @override
  State<CustomTextField1> createState() => _CustomTextField1State();
}

class _CustomTextField1State extends State<CustomTextField1> {
  final FocusNode _focusNode = FocusNode();
  Color _borderColor = const Color(0xffb5b5b5);
  Color _textColor = Colors.black;
  bool _obscureText = true;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    setState(() {
      if (_focusNode.hasFocus) {
        _borderColor = primaryColor();
        _textColor = Colors.black;
      } else {
        _borderColor = const Color(0xffb5b5b5);
        _textColor = Colors.black;
      }
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
          width: 400,
          height: 50,
          decoration: BoxDecoration(
            border: Border.all(
              color: _borderColor,
              width: 1, // Grosor del borde
            ),
            borderRadius: BorderRadius.circular(10), // Bordes redondeados
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: widget.controller,
                  obscureText: widget.isPassword && _obscureText,
                  focusNode: _focusNode,
                  decoration: InputDecoration(
                    hintText: widget.text,
                    border: InputBorder.none,
                    enabledBorder: InputBorder
                        .none, // Elimina el borde cuando el campo no está enfocado
                    focusedBorder: InputBorder
                        .none, // Elimina el borde cuando el campo está enfocado
                    errorBorder:
                        InputBorder.none, // Elimina el borde si hay error
                    disabledBorder: InputBorder
                        .none, // Elimina el borde si el campo está deshabilitado
                  ),
                  style: TextStyle(
                    color: _textColor,
                    fontWeight: FontWeight.w400,
                    fontSize: 16,
                  ),
                ),
              ),
              if (widget.isPassword)
                IconButton(
                  icon: Icon(
                    _obscureText
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: Colors.black,
                  ),
                  onPressed: _togglePasswordVisibility,
                ),
            ],
          ),
        ),
      ],
    );
  }
}
