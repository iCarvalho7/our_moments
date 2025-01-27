import 'package:flutter/material.dart';

import '../../utils/theme/app_theme.dart';

class BackgroundGradient extends StatelessWidget {
  const BackgroundGradient({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: AppColors.loginGradient,
          stops: [0.0, 1.0],
        ),
      ),
    );
  }
}
