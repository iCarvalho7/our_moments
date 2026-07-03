import 'package:flutter/material.dart';
import 'package:nossos_momentos/di/injection.dart';
import 'package:nossos_momentos/modules/core/premium/premium_feature.dart';
import 'package:nossos_momentos/modules/core/premium/premium_service.dart';
import 'package:nossos_momentos/modules/core/premium/widget/premium_gate.dart';
import 'package:nossos_momentos/modules/core/presenter/widgets/app_card.dart';
import 'package:nossos_momentos/modules/core/presenter/widgets/background_gradient.dart';
import 'package:nossos_momentos/modules/core/presenter/widgets/primary_app_bar.dart';
import 'package:nossos_momentos/modules/core/utils/theme/app_theme.dart';
import 'package:nossos_momentos/modules/moment/domain/entities/moment.dart';
import 'package:nossos_momentos/modules/time_line/couple_book/couple_book_service.dart';
import 'package:nossos_momentos/modules/time_line/domain/entity/time_line.dart';

import '../../bucket_list/presenter/page/bucket_list_page.dart';
import '../../special_dates/presenter/page/special_dates_page.dart';
import '../../time_capsule/presenter/page/time_capsule_page.dart';
import 'couple_stats_page.dart';
import 'year_in_review_page.dart';

/// Single discovery hub gathering every couple-tier feature in one place,
/// replacing the cluster of AppBar icons on the timeline.
///
/// The entry icon always opens this hub (for discovery); the gate happens
/// per-card on tap. Because the hub is a separate route — with no access to the
/// timeline's [TimeLineBloc] — it tracks whether any feature was unlocked during
/// the session and pops `true` so [TimeLinePage] can reload the timeline
/// (re-binding [PremiumService]) on return.
class CoupleFeaturesHubPage extends StatefulWidget {
  const CoupleFeaturesHubPage({
    super.key,
    required this.moments,
    required this.timeLine,
  });

  /// All moments loaded in memory (`TimeLineBloc.allMoments`) — used by stats,
  /// year-in-review and the couple book.
  final List<Moment> moments;

  /// The active timeline — used for titles, the time capsule emails and the
  /// couple book.
  final TimeLine timeLine;

  @override
  State<CoupleFeaturesHubPage> createState() => _CoupleFeaturesHubPageState();
}

class _CoupleFeaturesHubPageState extends State<CoupleFeaturesHubPage> {
  /// Set when the user unlocks premium during the session, signalling
  /// [TimeLinePage] to reload the timeline on return.
  bool _unlockedAny = false;

  bool _generatingBook = false;

  /// Runs the premium gate for [feature]. Returns `true` when the action may
  /// proceed (already unlocked, or just unlocked via the paywall). Records any
  /// unlock so the hub pops a reload signal on return.
  Future<bool> _ensure(PremiumFeature feature) async {
    if (getIt<PremiumService>().can(feature)) return true;
    final unlocked = await showPremiumPlaceholder(context, feature);
    if (unlocked) _unlockedAny = true;
    return unlocked;
  }

  Future<void> _openBucketList() async {
    if (!await _ensure(PremiumFeature.coupleBucketList)) return;
    if (!mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BucketListPage(timelineId: widget.timeLine.id),
      ),
    );
  }

  Future<void> _openSpecialDates() async {
    if (!await _ensure(PremiumFeature.specialDates)) return;
    if (!mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SpecialDatesPage(timelineId: widget.timeLine.id),
      ),
    );
  }

  Future<void> _openTimeCapsule() async {
    if (!await _ensure(PremiumFeature.timeCapsule)) return;
    if (!mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => TimeCapsulePage(
          timelineId: widget.timeLine.id,
          emails: widget.timeLine.emails,
        ),
      ),
    );
  }

  Future<void> _openCoupleStats() async {
    if (!await _ensure(PremiumFeature.momentAuthorStats)) return;
    if (!mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CoupleStatsPage(moments: widget.moments),
      ),
    );
  }

  Future<void> _openYearInReview() async {
    if (!await _ensure(PremiumFeature.yearInReview)) return;
    if (!mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => YearInReviewPage(
          moments: widget.moments,
          coupleName: widget.timeLine.name,
        ),
      ),
    );
  }

  /// Exports the whole timeline as a PDF album and opens the share sheet. Uses
  /// the moments already in memory (sorted oldest-first), so no extra fetch is
  /// needed. Shows progress while generating and a SnackBar on empty/error.
  Future<void> _exportCoupleBook() async {
    if (_generatingBook) return;
    if (!await _ensure(PremiumFeature.coupleBook)) return;
    if (!mounted) return;

    final moments = [...widget.moments]
      ..sort((a, b) => a.dateTime.compareTo(b.dateTime));
    final messenger = ScaffoldMessenger.of(context);
    if (moments.isEmpty) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Nenhum momento para exportar ainda.')),
      );
      return;
    }

    setState(() => _generatingBook = true);
    try {
      await getIt<CoupleBookService>().generateAndShare(
        timeline: widget.timeLine,
        moments: moments,
      );
    } catch (_) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Não foi possível gerar o livro de memórias.')),
      );
    } finally {
      if (mounted) setState(() => _generatingBook = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final service = getIt<PremiumService>();

    final features = <_HubFeature>[
      _HubFeature(
        icon: Icons.auto_awesome_outlined,
        title: 'Sonhos do grupo',
        description: 'Lista de desejos para realizarem juntos.',
        locked: !service.can(PremiumFeature.coupleBucketList),
        onTap: _openBucketList,
      ),
      _HubFeature(
        icon: Icons.event_outlined,
        title: 'Datas especiais',
        description: 'Aniversários e lembretes que importam.',
        locked: !service.can(PremiumFeature.specialDates),
        onTap: _openSpecialDates,
      ),
      _HubFeature(
        icon: Icons.mail_outline_rounded,
        title: 'Cápsula do tempo',
        description: 'Mensagens para abrir no futuro.',
        locked: !service.can(PremiumFeature.timeCapsule),
        onTap: _openTimeCapsule,
      ),
      _HubFeature(
        icon: Icons.insights_outlined,
        title: 'Estatísticas do grupo',
        description: 'Os números da história de vocês.',
        locked: !service.can(PremiumFeature.momentAuthorStats),
        onTap: _openCoupleStats,
      ),
      _HubFeature(
        icon: Icons.celebration_outlined,
        title: 'Retrospectiva do ano',
        description: 'Reviva os melhores momentos do ano.',
        locked: !service.can(PremiumFeature.yearInReview),
        onTap: _openYearInReview,
      ),
      _HubFeature(
        icon: Icons.menu_book_outlined,
        title: 'Livro de memórias (PDF)',
        description: 'Exporte tudo como um álbum em PDF.',
        locked: !service.can(PremiumFeature.coupleBook),
        loading: _generatingBook,
        onTap: _exportCoupleBook,
      ),
    ];

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        Navigator.of(context).pop(_unlockedAny);
      },
      child: Stack(
        children: [
          const BackgroundGradient(),
          Scaffold(
            backgroundColor: Colors.transparent,
            appBar: PrimaryAppBar(title: 'Recursos do grupo'),
            body: SafeArea(
              top: false,
              child: GridView.builder(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 0.92,
                ),
                itemCount: features.length,
                itemBuilder: (_, index) => _HubCard(feature: features[index]),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Plain description of one hub entry.
class _HubFeature {
  const _HubFeature({
    required this.icon,
    required this.title,
    required this.description,
    required this.locked,
    required this.onTap,
    this.loading = false,
  });

  final IconData icon;
  final String title;
  final String description;
  final bool locked;
  final bool loading;
  final Future<void> Function() onTap;
}

/// A single tappable feature card with an icon, title, one-line description and
/// a discreet padlock in the corner when the feature is still locked.
class _HubCard extends StatelessWidget {
  const _HubCard({required this.feature});

  final _HubFeature feature;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final textTheme = Theme.of(context).textTheme;

    return AppCard(
      onTap: feature.loading ? null : () => feature.onTap(),
      padding: const EdgeInsets.all(16),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: palette.primarySoft,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: feature.loading
                    ? Padding(
                        padding: const EdgeInsets.all(12),
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: palette.primary,
                        ),
                      )
                    : Icon(feature.icon, color: palette.primary, size: 24),
              ),
              const Spacer(),
              Text(
                feature.title,
                style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              Text(
                feature.description,
                style: textTheme.bodySmall?.copyWith(color: palette.onSurfaceMuted),
              ),
            ],
          ),
          if (feature.locked)
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: palette.surfaceAlt,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.lock_rounded, size: 14, color: palette.primary),
              ),
            ),
        ],
      ),
    );
  }
}
