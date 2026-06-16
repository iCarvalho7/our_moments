import 'package:flutter/material.dart';

import '../../utils/theme/app_theme.dart';

/// A sticky bottom bar with a soft upward "lift" shadow that hosts a primary
/// call-to-action (e.g. the "Registrar eternamente" button). It honors the
/// bottom safe area so the button never sits under the home indicator.
class FloatingCtaBar extends StatelessWidget {
  const FloatingCtaBar({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        14,
        16,
        14 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: palette.background,
        boxShadow: AppShadows.lift(context),
      ),
      child: child,
    );
  }
}
