import 'package:flutter/material.dart';
import 'package:vive_app/utils/styles.dart';

class CustomTextField extends StatefulWidget {
  final IconData icon;
  final bool isPassword;
  final String text;
  final TextEditingController controller;

  const CustomTextField({
    super.key,
    required this.icon,
    this.isPassword = false,
    required this.text,
    required this.controller,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
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
        _textColor = primaryColor();
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
          width: 400,
          margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 5),
          child: Text(
            widget.text,
            style: const TextStyle(
              fontWeight: FontWeight.bold, // Texto en negrita
              fontSize: 16,
            ),
            textAlign: TextAlign.left,
          ),
        ),
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
              Icon(
                widget.icon,
                color: _borderColor,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: widget.controller,
                  obscureText: widget.isPassword && _obscureText,
                  focusNode: _focusNode,
                  decoration: InputDecoration(
                    hintText: widget.text,
                    border: InputBorder.none,
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
