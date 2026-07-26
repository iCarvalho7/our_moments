import 'dart:async';
import 'dart:math';

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/utils/theme/app_theme.dart';

/// How big the celebration should feel. Scaled to the achievement so small
/// wins get a subtle nod and real milestones get a full celebration — keeping
/// the reward meaningful instead of numbing the user with constant confetti.
enum CelebrationTier {
  /// Everyday moment — a gentle, short burst.
  subtle,

  /// Default celebration for a freshly created moment.
  standard,

  /// A milestone (first moment, streak record, 100th moment, anniversary).
  milestone,
}

extension _TierTuning on CelebrationTier {
  int get particles => switch (this) {
        CelebrationTier.subtle => 10,
        CelebrationTier.standard => 22,
        CelebrationTier.milestone => 55,
      };

  Duration get blastDuration => switch (this) {
        CelebrationTier.subtle => const Duration(milliseconds: 500),
        CelebrationTier.standard => const Duration(milliseconds: 900),
        CelebrationTier.milestone => const Duration(milliseconds: 1600),
      };

  /// Total time the overlay stays on screen before auto-dismissing.
  Duration get holdDuration => switch (this) {
        CelebrationTier.subtle => const Duration(milliseconds: 1400),
        CelebrationTier.standard => const Duration(milliseconds: 1900),
        CelebrationTier.milestone => const Duration(milliseconds: 2600),
      };
}

/// Shows the moment-created celebration as a lightweight, auto-dismissing
/// overlay and completes once it has been dismissed. The caller decides what
/// to do next (typically pop the create page).
Future<void> showMomentCelebration(
  BuildContext context, {
  CelebrationTier tier = CelebrationTier.standard,
  String? achievementTitle,
}) {
  return showGeneralDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Momento eternizado',
    barrierColor: Colors.black.withValues(alpha: 0.45),
    transitionDuration: const Duration(milliseconds: 220),
    pageBuilder: (_, __, ___) => const SizedBox.shrink(),
    transitionBuilder: (dialogContext, animation, _, __) {
      return _MomentCelebration(
        tier: tier,
        achievementTitle: achievementTitle,
      );
    },
  );
}

class _MomentCelebration extends StatefulWidget {
  const _MomentCelebration({required this.tier, this.achievementTitle});

  final CelebrationTier tier;
  final String? achievementTitle;

  @override
  State<_MomentCelebration> createState() => _MomentCelebrationState();
}

class _MomentCelebrationState extends State<_MomentCelebration> {
  late final ConfettiController _confetti =
      ConfettiController(duration: widget.tier.blastDuration);
  Timer? _dismissTimer;

  @override
  void initState() {
    super.initState();
    _confetti.play();
    _dismissTimer = Timer(widget.tier.holdDuration, () {
      if (mounted) Navigator.of(context).maybePop();
    });
  }

  @override
  void dispose() {
    _dismissTimer?.cancel();
    _confetti.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final confettiColors = [
      palette.primary,
      palette.secondaryAccent,
      palette.romantic.accent,
      palette.happy.accent,
      palette.cool.accent,
    ];

    return GestureDetector(
      onTap: () => Navigator.of(context).maybePop(),
      behavior: HitTestBehavior.opaque,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Confetti rains down from the top center across the whole width.
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confetti,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              maxBlastForce: 22,
              minBlastForce: 8,
              gravity: 0.25,
              emissionFrequency: 0.04,
              numberOfParticles: widget.tier.particles,
              colors: confettiColors,
            ),
          ),
          _RewardCard(
            tier: widget.tier,
            achievementTitle: widget.achievementTitle,
          ),
        ],
      ),
    );
  }
}

class _RewardCard extends StatelessWidget {
  const _RewardCard({required this.tier, this.achievementTitle});

  final CelebrationTier tier;
  final String? achievementTitle;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final isMilestone = tier == CelebrationTier.milestone;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Container(
        padding: const EdgeInsets.fromLTRB(28, 30, 28, 26),
        decoration: BoxDecoration(
          color: palette.surface,
          borderRadius: BorderRadius.circular(AppRadii.hero),
          boxShadow: AppShadows.soft(context),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _HeartBadge(color: palette.primary, onColor: palette.onPrimary)
                .animate()
                .scale(
                  duration: 420.ms,
                  curve: Curves.elasticOut,
                  begin: const Offset(0.4, 0.4),
                  end: const Offset(1, 1),
                ),
            const SizedBox(height: 18),
            Text(
              'Momento eternizado 💛',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: palette.onSurface,
                  ),
            ),
            const SizedBox(height: 6),
            Text(
              isMilestone
                  ? 'Você desbloqueou algo especial!'
                  : 'Mais uma memória guardada com carinho.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: palette.onSurfaceMuted,
                  ),
            ),
            if (achievementTitle != null) ...[
              const SizedBox(height: 18),
              _AchievementChip(title: achievementTitle!)
                  .animate()
                  .fadeIn(delay: 260.ms, duration: 380.ms)
                  .slideY(begin: 0.4, end: 0, curve: Curves.easeOut),
            ],
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 240.ms)
        .scale(
          duration: 320.ms,
          curve: Curves.easeOutBack,
          begin: const Offset(0.85, 0.85),
          end: const Offset(1, 1),
        );
  }
}

class _HeartBadge extends StatelessWidget {
  const _HeartBadge({required this.color, required this.onColor});

  final Color color;
  final Color onColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, context.palette.secondaryAccent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
      ),
      child: Icon(Icons.favorite_rounded, color: onColor, size: 38),
    );
  }
}

class _AchievementChip extends StatelessWidget {
  const _AchievementChip({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: palette.primarySoft,
        borderRadius: BorderRadius.circular(AppRadii.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Transform.rotate(
            angle: pi / 12,
            child: Icon(Icons.emoji_events_rounded,
                size: 18, color: palette.primary),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              title,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: palette.primary,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
