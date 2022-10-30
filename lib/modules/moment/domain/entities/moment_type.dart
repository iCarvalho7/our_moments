import 'package:flutter/material.dart';

import '../../../core/utils/theme/app_theme.dart';

enum MomentType {
  bad  ('Ruim', AppColors.badColor),
  romantic ('Romantico', AppColors.romanticColor),
  good ('Bom', AppColors.goodColor);

  final String value;
  final Color color;

  const MomentType(this.value, this.color);
}