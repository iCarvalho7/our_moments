import 'package:flutter/material.dart';

import '../../utils/theme/app_theme.dart';

/// Full-bleed soft gradient used as the app's ambient background.
/// Adapts automatically to light / dark theme.
class BackgroundGradient extends StatelessWidget {
  const BackgroundGradient({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: context.palette.gradient,
            stops: const [0.0, 0.55],
          ),
        ),
      ),
    );
  }
}
