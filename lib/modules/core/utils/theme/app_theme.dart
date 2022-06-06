import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppThemes {
  static final TextStyle kBodySmallStyle =
      Fonts.interRegular.copyWith(fontSize: 10);

  static final TextStyle kBodyStyle = Fonts.interRegular.copyWith(fontSize: 14);

  static final TextStyle kLightBodyStyle =
      Fonts.interLight.copyWith(fontSize: 18);

  static final TextStyle kLightHeadLineStyle =
      Fonts.interLight.copyWith(fontSize: 24);

  static final TextStyle kLightTitleStyle =
      Fonts.interLight.copyWith(fontSize: 32);

  static final TextStyle kHeadLineStyle =
      Fonts.interRegular.copyWith(fontSize: 24);

  static final TextStyle kBodyLargeLineStyle =
      Fonts.interRegular.copyWith(fontSize: 18);

  static final TextStyle kTitleStyle = Fonts.interBold.copyWith(fontSize: 32);

  static final BoxDecoration circularBorder = BoxDecoration(
    border: Border.all(),
    color: Colors.white,
    shape: BoxShape.circle
  );

  static final BoxDecoration roundedBorder = BoxDecoration(
    border: Border.all(),
    color: Colors.white,
    borderRadius: const BorderRadius.all(
      Radius.circular(10),
    ),
  );

  static const BoxDecoration coloredBorder =  BoxDecoration(
    shape: BoxShape.circle,
    gradient: LinearGradient(
      colors: AppColors.instagramGradient,
    ),
  );

}

class AppColors {
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
  static final Widget iconHeart = Image.asset('assets/images/heart.png');
  static final Widget iconAddPhoto = Image.asset('assets/images/add_photo.png');
  static final Widget iconAddMoments = Image.asset('assets/images/icon_add_moments.png');
  static final Widget iconAddDateTime = Image.asset('assets/images/icon_add_date_time.png');
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
