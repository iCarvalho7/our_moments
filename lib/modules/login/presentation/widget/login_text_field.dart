import 'package:flutter/material.dart';

class LoginTextField extends StatelessWidget {
  const LoginTextField({
    super.key,
    required this.hint,
    required this.startIcon,
    required this.controller,
    this.errorText,
    this.endIcon,
    this.isPassword = false,
  });

  final String hint;
  final IconData startIcon;
  final IconData? endIcon;
  final String? errorText;
  final TextEditingController controller;
  final bool isPassword;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      textAlign: TextAlign.start,
      style: const TextStyle(
        fontFamily: 'GrandHotel',
        fontSize: 20,
      ),
      obscureText: isPassword,
      enableSuggestions: !isPassword,
      autocorrect: !isPassword,
      decoration: InputDecoration(
        hintText: hint,
        errorText: errorText,
        prefixIcon: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Icon(startIcon, size: 24),
        ),
        suffixIcon: endIcon != null
            ? Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: Icon(endIcon, size: 24),
              )
            : null,
      ),
    );
  }
}
