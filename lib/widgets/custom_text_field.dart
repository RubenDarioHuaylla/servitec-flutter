import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  const CustomTextField({
    super.key,
    required this.label,
    required this.hintText,
    required this.icon,
    this.validator,
    this.prefixText,
    this.keyboardType,
    required this.controller,
    this.maxLines = 1,
    this.obscureText = false,
    this.readOnly = false,
  });

  final String? Function(String?)? validator;
  final String label;
  final String hintText;
  final IconData icon;
  final String? prefixText;
  final TextInputType? keyboardType;
  final TextEditingController controller;
  final int maxLines;
  
  final bool obscureText;
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),

        const SizedBox(height: 8),

        TextFormField(
          controller: controller,
          validator: validator,
          keyboardType: keyboardType,
          maxLines: maxLines,
          obscureText: obscureText,
          readOnly: readOnly,
          decoration: InputDecoration(
            hintText: hintText,
            prefixIcon: Icon(icon),
            prefixText: prefixText,
            border: const OutlineInputBorder(),
          ),
        ),
      ],
    );
  }
}
