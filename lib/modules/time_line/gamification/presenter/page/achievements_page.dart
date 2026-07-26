import 'package:flutter/material.dart';
import 'package:nossos_momentos/di/injection.dart';

import '../../../../core/presenter/widgets/background_gradient.dart';
import '../../../../core/presenter/widgets/primary_app_bar.dart';
import '../../../../core/utils/theme/app_theme.dart';
import '../../../../login/domain/repository/auth_repository.dart';
import '../../../../moment/domain/entities/moment.dart';
import '../../../domain/entity/time_line.dart';
import '../../domain/entity/momentum_progress.dart';
import '../widget/achievement_tile.dart';
import '../widget/progress_card.dart';

typedef AchievementsArgs = ({List<Moment> moments, TimeLine timeLine});

/// Gamification for a single história, split into two tabs: everything in this
/// história (all its moments) and just what the current user contributed here.
/// Both are computed from the moments passed in — no persistence, mirroring the
/// [MomentCounts] idiom. The global personal profile lives in a separate page.
class AchievementsPage extends StatelessWidget {
  const AchievementsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as AchievementsArgs;
    final myEmail = getIt<AuthRepository>().getCurrentUser()?.email ?? '';

    final storyProgress = MomentumProgress.from(
      args.moments,
      relationshipStart: args.timeLine.relationshipStartDate,
    );
    final mine = args.moments.where((m) => m.author == myEmail).toList();
    final myProgress = MomentumProgress.from(
      mine,
      relationshipStart: args.timeLine.relationshipStartDate,
    );

    return DefaultTabController(
      length: 2,
      child: Stack(
        children: [
          const BackgroundGradient(),
          Scaffold(
            backgroundColor: Colors.transparent,
            appBar: PrimaryAppBar(
              title: 'Conquistas',
              bottom: const TabBar(
                tabs: [
                  Tab(text: 'Nesta história'),
                  Tab(text: 'Você aqui'),
                ],
              ),
            ),
            body: SafeArea(
              top: false,
              child: TabBarView(
                children: [
                  _ProgressTab(progress: storyProgress, title: 'Nível da história'),
                  _ProgressTab(progress: myProgress, title: 'Seu nível', personal: true),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressTab extends StatelessWidget {
  const _ProgressTab({required this.progress, required this.title, this.personal = false});

  final MomentumProgress progress;
  final String title;
  final bool personal;

  @override
  Widget build(BuildContext context) {
    final unlocked = progress.unlockedAchievements.length;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        ProgressCard(progress: progress, title: title),
        kSpacerHeight16,
        Row(
          children: [
            Expanded(
              child: StatTile(
                icon: Icons.local_fire_department_rounded,
                label: 'Sequência atual',
                value: '${progress.currentStreakDays} dias',
              ),
            ),
            kSpacerWidth12,
            Expanded(
              child: StatTile(
                icon: Icons.emoji_events_rounded,
                label: 'Maior sequência',
                value: '${progress.longestStreakDays} dias',
              ),
            ),
          ],
        ),
        kSpacerHeight24,
        Text(
          personal
              ? 'Suas conquistas aqui ($unlocked/${progress.achievements.length})'
              : 'Conquistas da história ($unlocked/${progress.achievements.length})',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        kSpacerHeight12,
        ...progress.achievements.map(
          (a) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: AchievementTile(achievement: a),
          ),
        ),
      ],
    );
  }
}
