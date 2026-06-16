import 'package:flutter/material.dart';

import '../../utils/theme/app_theme.dart';

/// The rounded content surface that "rides up" over a hero image — the signature
/// detail-screen shape (a sheet whose top corners overlap the image below it).
///
/// Place it in a [Column]/scroll view right after the hero and give it a
/// negative [overlap] so its rounded top sits on the image.
class OverlaySheet extends StatelessWidget {
  const OverlaySheet({
    super.key,
    required this.child,
    this.overlap = 24,
    this.padding = const EdgeInsets.fromLTRB(20, 22, 20, 20),
  });

  final Widget child;

  /// How far the sheet pulls up over the hero above it.
  final double overlap;

  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Transform.translate(
      offset: Offset(0, -overlap),
      child: Container(
        width: double.infinity,
        padding: padding,
        decoration: BoxDecoration(
          color: palette.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadii.sheet)),
        ),
        child: child,
      ),
    );
  }
}
