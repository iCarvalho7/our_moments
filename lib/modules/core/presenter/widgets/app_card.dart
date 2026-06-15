import 'package:flutter/material.dart';

import '../../utils/theme/app_theme.dart';

/// Modern surface card: rounded corners, soft ambient shadow, optional tap.
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(20),
    this.color,
    this.radius = AppRadii.card,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final Color? color;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final borderRadius = BorderRadius.circular(radius);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: color ?? palette.surface,
        borderRadius: borderRadius,
        border: Border.all(color: palette.outline),
        boxShadow: AppShadows.soft(context),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: borderRadius,
        child: InkWell(
          onTap: onTap,
          borderRadius: borderRadius,
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}
