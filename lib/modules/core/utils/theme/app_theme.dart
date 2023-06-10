import 'package:flutter/material.dart';

class AppThemes {
  static final BoxDecoration circularBorder = BoxDecoration(
    border: Border.all(color: Colors.transparent),
    color: Colors.white,
    shape: BoxShape.circle,
  );

  static final BoxDecoration roundedBorder = BoxDecoration(
    border: Border.all(color: Colors.white),
    color: Colors.white,
    borderRadius: const BorderRadius.all(
      Radius.circular(10),
    ),
  );

  static const BoxDecoration coloredBorder = BoxDecoration(
    shape: BoxShape.circle,
    gradient: LinearGradient(
      colors: AppColors.instagramGradient,
    ),
  );
}

class AppColors {
  static const Color timeLineColor = Color(0xFFF6A3A3);
  static const Color secondary = Color(0xffFFCFCF);
  static const Color calendarColor = Color(0xFFEBC8FC);
  static const Color romanticColor = Color(0xFFF308EA);
  static const Color badColor = Color(0xFFF30808);
  static const Color goodColor = Color(0xFF08F312);

  static const List<Color> instagramGradient = [
    Color(0xFFBF16EA),
    Color(0xFFD00A0A),
    Color(0xFFCBA622),
  ];
}

class Assets {
  static final Widget iconAddMoments = Image.asset('assets/images/icon_add_moments.png');
}

class Strings {
  static const appName = 'Nossos Momentos';
}
