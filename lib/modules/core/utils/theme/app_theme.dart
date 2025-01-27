import 'package:flutter/material.dart';

const kSpacerHeight32 = SizedBox(height: 32);
const kSpacerHeight16 = SizedBox(height: 16);

const kSpacerWidth32 = SizedBox(width: 32);
const kSpacerWidth16 = SizedBox(width: 16);
const kSpacerWidth8 = SizedBox(width: 8);

class AppThemes {
  static final BoxDecoration circularBorder = BoxDecoration(
    border: Border.all(color: Colors.transparent),
    color: Colors.white,
    shape: BoxShape.circle,
  );

  static final BoxDecoration roundedBorder = BoxDecoration(
    border: Border.all(color: Colors.white),
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
  static const Color romanticColor = Color(0xFFF8E1FA);
  static const Color badColor = Color(0xFFFAE1E1);
  static const Color goodColor = Color(0xFFE5FAE1);

  static const List<Color> instagramGradient = [
    Color(0xFFBF16EA),
    Color(0xFFD00A0A),
    Color(0xFFCBA622),
  ];

  static const List<Color> loginGradient = [
    Color(0xFFFFC5C5),
    Colors.white,
  ];
}

class Assets {
  static final Widget iconAddMoments = Image.asset('assets/images/icon_add_moments.png');
}

class Strings {
  static const appName = 'Nossos Momentos';
}
