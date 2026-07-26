import 'package:flutter/material.dart';

import '../../../../moment/domain/entities/moment.dart';
import 'moment_achievement.dart';

/// Pure, in-memory gamification snapshot computed from a list of moments —
/// following the same "no repository, no persistence" idiom as [MomentCounts].
/// Everything here is derivable from the moments the feed already holds, so no
/// denormalized fields, Firestore rules or write-contention are introduced.
///
/// Reused for both levels of identity:
/// - **per-história**: pass a single timeline's moments;
/// - **personal (aggregate)**: pass the user's authored moments across every
///   timeline, plus [distinctTimelines] to unlock the personal-only badges.
class MomentumProgress {
  const MomentumProgress({
    required this.totalMoments,
    required this.currentStreakDays,
    required this.longestStreakDays,
    required this.points,
    required this.level,
    required this.pointsIntoLevel,
    required this.pointsForNextLevel,
    required this.achievements,
  });

  final int totalMoments;

  /// Consecutive calendar days (of documented moments) ending on the most
  /// recent moment day. "Active" when that day is today or yesterday.
  final int currentStreakDays;

  final int longestStreakDays;

  final int points;
  final int level;

  /// Points accumulated within the current level, and how many the level spans.
  final int pointsIntoLevel;
  final int pointsForNextLevel;

  /// Full catalog, each carrying its own progress/unlocked state.
  final List<MomentAchievement> achievements;

  List<MomentAchievement> get unlockedAchievements => achievements.where((a) => a.unlocked).toList();

  double get levelProgress =>
      pointsForNextLevel == 0 ? 1 : (pointsIntoLevel / pointsForNextLevel).clamp(0, 1).toDouble();

  /// Every 250 points is a level. Kept simple and deterministic.
  static const int _pointsPerLevel = 250;

  factory MomentumProgress.from(
    List<Moment> moments, {
    DateTime? relationshipStart,
    DateTime? now,
    int? distinctTimelines,
  }) {
    final reference = now ?? DateTime.now();
    final total = moments.length;

    // Points: reward documenting richly (a photo/location/voice note adds up).
    var points = 0;
    var withLocation = 0;
    var withPhoto = 0;
    var withAudio = 0;
    for (final m in moments) {
      points += 10;
      if (m.uploadedImgList.isNotEmpty) {
        points += 5;
        withPhoto++;
      }
      if (m.hasLocation) {
        points += 5;
        withLocation++;
      }
      if (m.hasAudio) {
        points += 5;
        withAudio++;
      }
      if (m.isFavorite) points += 3;
    }

    final level = (points ~/ _pointsPerLevel) + 1;
    final pointsIntoLevel = points % _pointsPerLevel;

    final (current, longest) = _streaks(moments, reference);

    final togetherDays = relationshipStart == null
        ? 0
        : DateTime(
            reference.year,
            reference.month,
            reference.day,
          ).difference(DateTime(relationshipStart.year, relationshipStart.month, relationshipStart.day)).inDays;

    // Neutral catalog — copy works for a solo, romantic or group história.
    final achievements = <MomentAchievement>[
      MomentAchievement(
        id: 'first_moment',
        title: 'Primeiro momento',
        description: 'Registre a primeira memória.',
        icon: Icons.auto_awesome_rounded,
        current: total.clamp(0, 1),
        target: 1,
      ),
      MomentAchievement(
        id: 'ten_moments',
        title: 'Colecionador',
        description: 'Registre 10 momentos.',
        icon: Icons.collections_bookmark_rounded,
        current: total,
        target: 10,
      ),
      MomentAchievement(
        id: 'hundred_moments',
        title: 'Uma vida de histórias',
        description: 'Registre 100 momentos.',
        icon: Icons.local_fire_department_rounded,
        current: total,
        target: 100,
      ),
      MomentAchievement(
        id: 'week_streak',
        title: '7 dias seguidos',
        description: 'Documente 7 dias consecutivos.',
        icon: Icons.bolt_rounded,
        current: longest,
        target: 7,
      ),
      MomentAchievement(
        id: 'first_trip',
        title: 'Primeira viagem',
        description: 'Registre um momento com localização.',
        icon: Icons.place_rounded,
        current: withLocation.clamp(0, 1),
        target: 1,
      ),
      MomentAchievement(
        id: 'voice_keepsake',
        title: 'Recado de voz',
        description: 'Guarde um momento com um recado de voz.',
        icon: Icons.mic_rounded,
        current: withAudio.clamp(0, 1),
        target: 1,
      ),
      MomentAchievement(
        id: 'photographer',
        title: 'Olhar de fotógrafo',
        description: 'Registre 20 momentos com foto.',
        icon: Icons.photo_camera_rounded,
        current: withPhoto,
        target: 20,
      ),
      MomentAchievement(
        id: 'one_year',
        title: '1 ano de história',
        description: 'Complete 1 ano registrando memórias.',
        icon: Icons.favorite_rounded,
        current: total > 0 ? togetherDays : 0,
        target: 365,
      ),
      // Personal-only: only meaningful when aggregating across timelines.
      if (distinctTimelines != null)
        MomentAchievement(
          id: 'many_chapters',
          title: 'Muitas histórias',
          description: 'Documente 3 histórias diferentes.',
          icon: Icons.auto_stories_rounded,
          current: distinctTimelines,
          target: 3,
        ),
    ];

    return MomentumProgress(
      totalMoments: total,
      currentStreakDays: current,
      longestStreakDays: longest,
      points: points,
      level: level,
      pointsIntoLevel: pointsIntoLevel,
      pointsForNextLevel: _pointsPerLevel,
      achievements: achievements,
    );
  }

  /// Returns (currentStreak, longestStreak) over the distinct calendar days
  /// that have at least one moment. The current streak is the run ending on the
  /// latest documented day, and only counts as "current" if that day is today
  /// or yesterday relative to [reference].
  static (int, int) _streaks(List<Moment> moments, DateTime reference) {
    if (moments.isEmpty) return (0, 0);

    final days = <DateTime>{
      for (final m in moments) DateTime(m.dateTime.year, m.dateTime.month, m.dateTime.day),
    }.toList()..sort();

    var longest = 1;
    var run = 1;
    for (var i = 1; i < days.length; i++) {
      final gap = days[i].difference(days[i - 1]).inDays;
      if (gap == 1) {
        run++;
      } else {
        run = 1;
      }
      if (run > longest) longest = run;
    }

    // Current streak: walk back from the latest day while days are consecutive.
    final today = DateTime(reference.year, reference.month, reference.day);
    final latest = days.last;
    final sinceLatest = today.difference(latest).inDays;
    var current = 0;
    if (sinceLatest <= 1) {
      current = 1;
      for (var i = days.length - 1; i > 0; i--) {
        if (days[i].difference(days[i - 1]).inDays == 1) {
          current++;
        } else {
          break;
        }
      }
    }

    return (current, longest);
  }
}
