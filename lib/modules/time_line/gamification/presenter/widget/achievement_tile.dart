import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/presenter/widgets/app_card.dart';
import '../../../../core/utils/theme/app_theme.dart';
import '../../domain/entity/moment_achievement.dart';

/// A small stat card (streak, longest run, etc.). Shared by the per-história
/// achievements screen and the personal profile.
class StatTile extends StatelessWidget {
  const StatTile({super.key, required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final textTheme = Theme.of(context).textTheme;
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: palette.primary, size: 22),
          kSpacerHeight8,
          Text(value, style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 2),
          Text(label, style: textTheme.bodySmall?.copyWith(color: palette.onSurfaceMuted)),
        ],
      ),
    );
  }
}

/// A single achievement row: unlocked (highlighted + check) or locked (with a
/// progress bar toward its target).
class AchievementTile extends StatelessWidget {
  const AchievementTile({super.key, required this.achievement});

  final MomentAchievement achievement;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final textTheme = Theme.of(context).textTheme;
    final unlocked = achievement.unlocked;
    final accent = unlocked ? palette.primary : palette.onSurfaceMuted;

    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: unlocked ? palette.primarySoft : palette.surfaceAlt,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(achievement.icon, color: accent, size: 22),
          ),
          kSpacerWidth12,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        achievement.title,
                        style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                      ),
                    ),
                    if (unlocked)
                      Icon(Icons.check_circle_rounded, color: palette.primary, size: 18),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  achievement.description,
                  style: textTheme.bodySmall?.copyWith(color: palette.onSurfaceMuted),
                ),
                if (!unlocked) ...[
                  kSpacerHeight8,
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadii.pill),
                    child: Stack(
                      children: [
                        Container(height: 6, color: palette.surfaceAlt),
                        FractionallySizedBox(
                          widthFactor: achievement.progress == 0 ? 0.02 : achievement.progress,
                          child: Container(height: 6, color: palette.primary)
                              .animate()
                              .fadeIn(duration: 300.ms),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${achievement.current.clamp(0, achievement.target)}/${achievement.target}',
                    style: textTheme.labelSmall?.copyWith(color: palette.onSurfaceMuted),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
