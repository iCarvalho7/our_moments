import 'package:flutter/material.dart';

import '../../../../core/presenter/widgets/background_gradient.dart';
import '../../../../core/presenter/widgets/primary_app_bar.dart';
import '../../../../core/utils/theme/app_theme.dart';
import '../../../../moment/domain/entities/moment.dart';
import '../../domain/entity/momentum_progress.dart';
import '../widget/achievement_tile.dart';
import '../widget/progress_card.dart';

typedef PersonalProfileArgs = ({List<Moment> moments, int timelineCount});

/// The identity that follows the user across the whole app: their level, streak
/// and achievements aggregated over the moments they authored in *every*
/// história. Computed in memory from the feed's already-loaded moments.
class PersonalProfilePage extends StatelessWidget {
  const PersonalProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as PersonalProfileArgs;
    final progress = MomentumProgress.from(
      args.moments,
      distinctTimelines: args.timelineCount,
    );
    final unlocked = progress.unlockedAchievements.length;
    final textTheme = Theme.of(context).textTheme;

    return Stack(
      children: [
        const BackgroundGradient(),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: PrimaryAppBar(title: 'Seu perfil'),
          body: SafeArea(
            top: false,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              children: [
                ProgressCard(progress: progress, title: 'Seu nível'),
                kSpacerHeight16,
                Row(
                  children: [
                    Expanded(
                      child: StatTile(
                        icon: Icons.local_fire_department_rounded,
                        label: 'Sua sequência',
                        value: '${progress.currentStreakDays} dias',
                      ),
                    ),
                    kSpacerWidth12,
                    Expanded(
                      child: StatTile(
                        icon: Icons.auto_stories_rounded,
                        label: 'Histórias',
                        value: '${args.timelineCount}',
                      ),
                    ),
                  ],
                ),
                kSpacerHeight24,
                Text(
                  'Suas conquistas ($unlocked/${progress.achievements.length})',
                  style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
                kSpacerHeight12,
                ...progress.achievements.map(
                  (a) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: AchievementTile(achievement: a),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
