import 'package:flutter/material.dart';

import '../../../core/utils/theme/app_theme.dart';

class LoginTextField extends StatefulWidget {
  const LoginTextField({
    super.key,
    required this.hint,
    this.startIcon,
    required this.controller,
    this.errorText,
    this.endIcon,
    this.endIconPressed,
    this.isPassword = false,
  });

  final String hint;
  final IconData? startIcon;
  final IconData? endIcon;
  final Function()? endIconPressed;
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
    final palette = context.palette;

    return TextField(
      controller: widget.controller,
      textAlign: TextAlign.start,
      style: Theme.of(context).textTheme.bodyLarge,
      cursorColor: palette.primary,
      obscureText: widget.isPassword ? !isPasswordVisible : false,
      enableSuggestions: !widget.isPassword,
      autocorrect: !widget.isPassword,
      decoration: InputDecoration(
        hintText: widget.hint,
        errorText: widget.errorText,
        prefixIcon: widget.startIcon != null ? Icon(widget.startIcon, size: 22) : null,
        suffixIcon: widget.endIcon != null
            ? IconButton(
                splashRadius: 22,
                onPressed: () {
                  if (widget.isPassword) {
                    setState(() => isPasswordVisible = !isPasswordVisible);
                  }
                  widget.endIconPressed?.call();
                },
                icon: Icon(
                  widget.isPassword
                      ? (isPasswordVisible ? Icons.visibility_off : widget.endIcon)
                      : widget.endIcon,
                  size: 22,
                ),
              )
            : null,
      ),
    );
  }
}
