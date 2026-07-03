import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../core/utils/theme/app_theme.dart';

enum MomentType {
  bad('Ruim', 'Ruim', Icons.sentiment_dissatisfied_rounded),
  // NOTE: `value` is the string persisted in the database — do NOT change it
  // (it is matched on read). `label` is the display text.
  romantic('Romantico', 'Romântico', CupertinoIcons.heart_fill),
  good('Bom', 'Bom', Icons.sentiment_satisfied_alt_rounded),
  sad('sad', 'Triste', Icons.sentiment_very_dissatisfied_rounded),
  happy('happy', 'Feliz', Icons.sentiment_very_satisfied_rounded),
  cool('cool', 'Legal', Icons.thumb_up_alt_rounded),
  awful('awful', 'Horrível', Icons.sick_rounded),
  disaster('disaster', 'Desgraça', Icons.thunderstorm_outlined);

  /// Serialized value stored in the database (must stay stable).
  final String value;

  /// Human-facing label shown in the UI.
  final String label;

  final IconData icon;

  const MomentType(this.value, this.label, this.icon);

  /// Theme-aware color set (background / accent / on-background) for this type.
  MomentColors colors(BuildContext context) {
    final palette = context.palette;
    switch (this) {
      case MomentType.bad:
        return palette.bad;
      case MomentType.romantic:
        return palette.romantic;
      case MomentType.good:
        return palette.good;
      case MomentType.sad:
        return palette.sad;
      case MomentType.happy:
        return palette.happy;
      case MomentType.cool:
        return palette.cool;
      case MomentType.awful:
        return palette.awful;
      case MomentType.disaster:
        return palette.disaster;
    }
  }
}
