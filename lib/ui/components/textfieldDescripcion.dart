import 'package:flutter/material.dart';
import 'package:vive_app/utils/styles.dart';

class CustomTextFieldDescription extends StatefulWidget {
  final bool isPassword;
  final String text;
  final TextEditingController controller;
  final int maxLines;
  final int minLines;

  const CustomTextFieldDescription({
    super.key,
    this.isPassword = false,
    required this.text,
    required this.controller,
    this.maxLines = 1,  // Default para un campo de una línea
    this.minLines = 1,  // Default para una línea mínima
  });

  @override
  State<CustomTextFieldDescription> createState() => CustomTextFieldDescriptionState();
}

class CustomTextFieldDescriptionState extends State<CustomTextFieldDescription> {
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
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          width: 400,  // Puedes ajustar este valor según sea necesario
          decoration: BoxDecoration(
            border: Border.all(
              color: _borderColor,
              width: 1,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: widget.controller,
                  obscureText: widget.isPassword && _obscureText,
                  focusNode: _focusNode,
                  maxLines: widget.maxLines,  // Configura el número máximo de líneas
                  minLines: widget.minLines,  // Configura el número mínimo de líneas
                  keyboardType: widget.isPassword
                      ? TextInputType.text
                      : TextInputType.multiline,  // Soporte para multilinea
                  decoration: InputDecoration(
                    hintText: widget.text,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
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
