import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/presenter/widgets/app_card.dart';
import '../../../../core/utils/theme/app_theme.dart';
import '../../domain/entity/momentum_progress.dart';

/// Card that surfaces gamification progress: level, points bar, current streak
/// and the next achievement to chase. Purely presentational — fed a
/// [MomentumProgress] computed from moments already in memory. [title] lets the
/// caller phrase the level line for the personal or per-história context.
class ProgressCard extends StatelessWidget {
  const ProgressCard({
    super.key,
    required this.progress,
    this.title = 'Nível',
    this.onTap,
  });

  final MomentumProgress progress;
  final String title;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final textTheme = Theme.of(context).textTheme;

    final nextAchievement = progress.achievements.firstWhere(
      (a) => !a.unlocked,
      orElse: () => progress.achievements.last,
    );

    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [palette.primary, palette.secondaryAccent],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${progress.level}',
                  style: textTheme.titleMedium
                      ?.copyWith(color: palette.onPrimary, fontWeight: FontWeight.w800),
                ),
              ),
              kSpacerWidth12,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('$title ${progress.level}',
                        style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 2),
                    Text('${progress.points} pontos • ${progress.totalMoments} momentos',
                        style: textTheme.bodySmall?.copyWith(color: palette.onSurfaceMuted)),
                  ],
                ),
              ),
              if (progress.currentStreakDays > 0)
                _StreakPill(days: progress.currentStreakDays),
            ],
          ),
          kSpacerHeight16,
          _LevelBar(value: progress.levelProgress),
          const SizedBox(height: 6),
          Text(
            '${progress.pointsForNextLevel - progress.pointsIntoLevel} pontos para o nível ${progress.level + 1}',
            style: textTheme.labelSmall?.copyWith(color: palette.onSurfaceMuted),
          ),
          kSpacerHeight16,
          Row(
            children: [
              Icon(nextAchievement.icon, size: 18, color: palette.primary),
              kSpacerWidth8,
              Expanded(
                child: Text(
                  nextAchievement.unlocked
                      ? 'Todas as conquistas desbloqueadas! 🎉'
                      : 'Próxima: ${nextAchievement.title}',
                  style: textTheme.bodySmall,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LevelBar extends StatelessWidget {
  const _LevelBar({required this.value});

  final double value;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadii.pill),
      child: Stack(
        children: [
          Container(height: 10, color: palette.surfaceAlt),
          FractionallySizedBox(
            widthFactor: value == 0 ? 0.02 : value,
            child: Container(
              height: 10,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [palette.primary, palette.secondaryAccent],
                ),
              ),
            ),
          ).animate().fadeIn(duration: 300.ms),
        ],
      ),
    );
  }
}

class _StreakPill extends StatelessWidget {
  const _StreakPill({required this.days});

  final int days;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: palette.primarySoft,
        borderRadius: BorderRadius.circular(AppRadii.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🔥', style: TextStyle(fontSize: 13)),
          const SizedBox(width: 4),
          Text(
            '$days',
            style: Theme.of(context)
                .textTheme
                .labelMedium
                ?.copyWith(color: palette.primary, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}
