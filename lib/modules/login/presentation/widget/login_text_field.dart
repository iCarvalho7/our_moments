import 'package:flutter/material.dart';

class LoginTextField extends StatefulWidget {
  const LoginTextField({
    super.key,
    required this.hint,
    this.startIcon,
    required this.controller,
    this.errorText,
    this.endIcon,
    this.isPassword = false,
  });

  final String hint;
  final IconData? startIcon;
  final IconData? endIcon;
  final String? errorText;
  final TextEditingController controller;
  final bool isPassword;

  @override
  State<LoginTextField> createState() => _LoginTextFieldState();
}

class _LoginTextFieldState extends State<LoginTextField> {
  bool isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      textAlign: TextAlign.start,
      style: const TextStyle(
        fontFamily: 'GrandHotel',
        fontSize: 20,
      ),
      obscureText: widget.isPassword ? !isPasswordVisible : false,
      enableSuggestions: !widget.isPassword,
      autocorrect: !widget.isPassword,
      decoration: InputDecoration(
        hintText: widget.hint,
        errorText: widget.errorText,
        prefixIcon: widget.startIcon != null
            ? Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Icon(widget.startIcon, size: 24),
              )
            : null,
        suffixIcon: widget.endIcon != null
            ? GestureDetector(
                onTap: () {
                  if (widget.isPassword) {
                    setState(() {
                      isPasswordVisible = !isPasswordVisible;
                    });
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: Icon(
                    widget.isPassword
                        ? isPasswordVisible
                            ? Icons.visibility_off
                            : widget.endIcon
                        : widget.endIcon,
                    size: 24,
                  ),
                ),
              )
            : null,
      ),
    );
  }
}
