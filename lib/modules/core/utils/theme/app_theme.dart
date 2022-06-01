import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppThemes {
  static final TextStyle kBodySmallStyle =
      Fonts.interRegular.copyWith(fontSize: 10);

  static final TextStyle kBodyStyle = Fonts.interRegular.copyWith(fontSize: 14);

  static final TextStyle kLightHeadLineStyle =
      Fonts.interLight.copyWith(fontSize: 24);

  static final TextStyle kHeadLineStyle =
      Fonts.interRegular.copyWith(fontSize: 24);

  static final TextStyle kBodyLargeLineStyle =
      Fonts.interRegular.copyWith(fontSize: 18);

  static final TextStyle kTitleStyle = Fonts.interBold.copyWith(fontSize: 32);

  static final BoxDecoration roundedBorder = BoxDecoration(
    border: Border.all(),
    color: Colors.white,
    borderRadius: const BorderRadius.all(
      Radius.circular(10),
    ),
  );

  static const Color pinkAccent = Color(0xFFFFCFCF);
}

class Assets {
  static final Widget iconHeart = Image.asset('assets/images/heart.png');
  static final Widget iconAddPhoto = Image.asset('assets/images/add_photo.png');
  static final Widget iconAddMoments = Image.asset('assets/images/icon_add_moments.png');
}

class Fonts {
  static final TextStyle interRegular = GoogleFonts.inter();

  static final TextStyle interBold = GoogleFonts.inter(
    fontWeight: FontWeight.bold,
  );

  static final TextStyle interLight = GoogleFonts.inter(
    fontWeight: FontWeight.w300,
  );
}
