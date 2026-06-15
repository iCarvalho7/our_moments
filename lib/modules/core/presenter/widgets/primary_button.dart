import 'package:flutter/material.dart';

import '../../utils/theme/app_theme.dart';

/// Hero call-to-action button with a coral gradient fill and soft glow.
/// Falls back to a muted style when [onPressed] is null.
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.expand = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final enabled = onPressed != null;
    final radius = BorderRadius.circular(AppRadii.button);

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: radius,
        gradient: LinearGradient(
          colors: enabled
              ? [palette.primary, palette.secondaryAccent]
              : [palette.surfaceAlt, palette.surfaceAlt],
        ),
        boxShadow: enabled
            ? [
                BoxShadow(
                  color: palette.primary.withValues(alpha: 0.35),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: radius,
        child: InkWell(
          onTap: onPressed,
          borderRadius: radius,
          child: Container(
            height: 54,
            alignment: Alignment.center,
            width: expand ? double.infinity : null,
            padding: expand ? null : const EdgeInsets.symmetric(horizontal: 28),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(icon, color: enabled ? palette.onPrimary : palette.onSurfaceMuted, size: 20),
                  kSpacerWidth8,
                ],
                Text(
                  label,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: enabled ? palette.onPrimary : palette.onSurfaceMuted,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
