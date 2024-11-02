import 'package:flutter/material.dart';
import 'package:vive_app/utils/styles.dart';

class CustomCheckRow extends StatefulWidget {
  final bool isChecked;
  final ValueChanged<bool> onChanged;

  const CustomCheckRow({
    super.key,
    required this.isChecked,
    required this.onChanged,
  });

  @override
  _CustomCheckRowState createState() => _CustomCheckRowState();
}

class _CustomCheckRowState extends State<CustomCheckRow> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 400,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        children: [
          Checkbox(
            value: widget.isChecked,
            activeColor: primaryColor(),
            onChanged: (bool? value) {
              widget.onChanged(value ?? false);
            },
          ),
          const Text(
            'Mantener sesión iniciada',
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}
