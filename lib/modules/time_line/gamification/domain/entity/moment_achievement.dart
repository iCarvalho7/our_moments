import 'package:flutter/material.dart';

/// A single achievement, evaluated purely from a list of moments. Mirrors the
/// project's icon-in-domain style (see MomentType) so the UI can render it
/// without a separate mapping layer. Used for both the personal (aggregate)
/// and per-história progress views.
class MomentAchievement {
  const MomentAchievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.current,
    required this.target,
  });

  /// Stable identifier persisted nowhere but used to diff "newly unlocked".
  final String id;
  final String title;
  final String description;
  final IconData icon;

  /// Progress toward unlocking: [current] out of [target].
  final int current;
  final int target;

  bool get unlocked => current >= target;

  /// 0..1 progress, clamped.
  double get progress => target == 0 ? 1 : (current / target).clamp(0, 1).toDouble();

  MomentAchievement copyWith({int? current}) => MomentAchievement(
        id: id,
        title: title,
        description: description,
        icon: icon,
        current: current ?? this.current,
        target: target,
      );
}
