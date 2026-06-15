import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../utils/theme/app_theme.dart';

class LoadingEffect extends StatelessWidget {
  final Widget child;

  const LoadingEffect({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Shimmer.fromColors(
      baseColor: palette.surfaceAlt,
      highlightColor: palette.isDark ? palette.surface : Colors.white,
      child: child,
    );
  }
}
