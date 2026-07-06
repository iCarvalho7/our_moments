import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nossos_momentos/di/injection.dart';
import 'package:nossos_momentos/modules/core/presenter/routes.dart';
import 'package:nossos_momentos/modules/core/presenter/widgets/background_gradient.dart';
import 'package:nossos_momentos/modules/core/presenter/widgets/app_bottom_nav.dart';
import 'package:nossos_momentos/modules/core/presenter/widgets/app_network_image.dart';
import 'package:nossos_momentos/modules/core/presenter/widgets/loading_effect.dart';
import 'package:nossos_momentos/modules/core/presenter/widgets/primary_app_bar.dart';
import 'package:nossos_momentos/modules/core/utils/theme/app_theme.dart';
import 'package:nossos_momentos/modules/moment/interactions/presenter/bloc/interactions_bloc.dart';
import 'package:nossos_momentos/modules/moment/domain/entities/moment.dart';
import 'package:nossos_momentos/modules/moment/presenter/bloc/add_or_edit_moment_bloc.dart';

import '../../domain/entity/time_line.dart';
import '../../domain/entity/timeline_permissions.dart';
import '../bloc/new_feed_cubit.dart';
import '../widgets/new_moment_feed_card.dart';

/// Social-feed home: every timeline the user belongs to and its moments merged
/// into a single chronological stream, with a per-timeline filter row.
class NewSelectTimeLinePage extends StatefulWidget {
  const NewSelectTimeLinePage({super.key});

  @override
  State<NewSelectTimeLinePage> createState() => _NewSelectTimeLinePageState();
}

class _NewSelectTimeLinePageState extends State<NewSelectTimeLinePage> {
  final _scrollController = ScrollController();
  double _savedScrollOffset = 0;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToTop() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(0, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    }
  }

  Future<void> _onCreate(BuildContext context) async {
    final cubitState = context.read<NewFeedCubit>().state;
    if (cubitState is! NewFeedLoaded) return;
    final editable = cubitState.timelines
        .where((tl) => TimelinePermissions.canEdit(tl, cubitState.currentUserEmail))
        .toList();
    if (editable.isEmpty) return;

    TimeLine? target;
    if (editable.length == 1) {
      target = editable.first;
    } else if (cubitState.activeTimelineId != null) {
      final active = editable.where((tl) => tl.id == cubitState.activeTimelineId).toList();
      if (active.isNotEmpty) target = active.first;
    }

    target ??= await _pickTimeline(context, editable);
    if (target == null || !context.mounted) return;
    _openAdd(context, target);
  }

  Future<TimeLine?> _pickTimeline(BuildContext context, List<TimeLine> editable) {
    return showModalBottomSheet<TimeLine>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _TimelinePickerSheet(timelines: editable),
    );
  }

  void _openTimeline(BuildContext context) {
    final cubitState = context.read<NewFeedCubit>().state;
    String? id;
    if (cubitState is NewFeedLoaded) {
      id = cubitState.activeTimelineId ?? (cubitState.timelines.isNotEmpty ? cubitState.timelines.first.id : null);
    }
    if (id == null) return;
    Navigator.pushNamed(
      context,
      AppRoute.momentsMap.tag,
    ).then((_) => context.mounted ? context.read<NewFeedCubit>().load() : null);
  }

  void _openAdd(BuildContext context, TimeLine timeline) {
    final cubit = context.read<NewFeedCubit>();
    _savedScrollOffset = _scrollController.hasClients ? _scrollController.offset : 0;
    context.read<AddOrEditMomentBloc>().add(SetupAddMomentEvent(timelineId: timeline.id));
    Navigator.pushNamed(
      context,
      AppRoute.addMoment.tag,
      arguments: (
        accentColor: timeline.accentColor,
        endDate: timeline.enforceEndDate ? timeline.relationshipEndDate : null,
      ),
    ).then((_) => cubit.load());
  }

  void _openTimelineSettings(BuildContext context, String timelineId) {
    final cubit = context.read<NewFeedCubit>();
    Navigator.pushNamed(
      context,
      AppRoute.timeLine.tag,
      arguments: timelineId,
    ).then((_) => context.mounted ? cubit.load() : null);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<NewFeedCubit>()..load(),
      child: Builder(
        builder: (context) {
          return Stack(
            children: [
              const BackgroundGradient(),
              Scaffold(
                backgroundColor: Colors.transparent,
                appBar: const PrimaryAppBar(title: 'Nossos Momentos'),
                body: SafeArea(
                  child: BlocConsumer<NewFeedCubit, NewFeedState>(
                    listener: (context, state) {
                      if (state is NewFeedLoaded && _savedScrollOffset > 0) {
                        final offset = _savedScrollOffset;
                        _savedScrollOffset = 0;
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (_scrollController.hasClients) {
                            _scrollController.jumpTo(offset.clamp(0.0, _scrollController.position.maxScrollExtent));
                          }
                        });
                      }
                    },
                    builder: _buildFeedBody,
                  ),
                ),
                bottomNavigationBar: AppBottomNav(
                  items: [
                    AppNavItem(icon: Icons.home_rounded, label: 'Início', onTap: _scrollToTop),
                    AppNavItem(icon: Icons.timeline_rounded, label: 'Mapa', onTap: () => _openTimeline(context)),
                    AppNavItem(icon: Icons.add_rounded, label: 'Criar', primary: true, onTap: () => _onCreate(context)),
                    AppNavItem(
                      icon: Icons.travel_explore_rounded,
                      label: 'Momentos',
                      onTap: () => Navigator.pushNamed(context, AppRoute.allTimelinesMap.tag),
                    ),
                    AppNavItem(
                      icon: Icons.settings_outlined,
                      label: 'Ajustes',
                      onTap: () => Navigator.pushNamed(context, AppRoute.accountSettings.tag),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFeedBody(BuildContext context, NewFeedState state) {
    if (state is NewFeedLoading || state is NewFeedInitial) {
      final palette = context.palette;
      return ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: 3,
        itemBuilder: (_, __) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: LoadingEffect(
            child: Container(
              height: 180,
              decoration: BoxDecoration(color: palette.surface, borderRadius: BorderRadius.circular(AppRadii.card)),
            ),
          ),
        ),
      );
    }

    if (state is NewFeedError) {
      final textTheme = Theme.of(context).textTheme;
      final palette = context.palette;
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                kDebugMode ? state.error : 'Não foi possível carregar seus momentos.',
                textAlign: TextAlign.center,
                style: textTheme.bodyMedium?.copyWith(color: palette.onSurfaceMuted),
              ),
              kSpacerHeight12,
              TextButton(onPressed: () => context.read<NewFeedCubit>().load(), child: const Text('Tentar novamente')),
            ],
          ),
        ),
      );
    }

    final loaded = state as NewFeedLoaded;
    final cubit = context.read<NewFeedCubit>();
    final timelineById = {for (final t in loaded.timelines) t.id: t};

    final List<_FeedItem> feedItems = [];
    String? lastKey;
    for (final moment in loaded.moments) {
      final dt = moment.dateTime;
      final key = '${dt.year}-${dt.month.toString().padLeft(2, '0')}';
      if (key != lastKey) {
        final raw = DateFormat('MMMM yyyy', 'pt_BR').format(dt);
        feedItems.add(_FeedMonthHeader(raw[0].toUpperCase() + raw.substring(1)));
        lastKey = key;
      }
      feedItems.add(_FeedMomentItem(moment));
    }

    return RefreshIndicator(
      onRefresh: () => cubit.load(),
      child: CustomScrollView(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: _TimelineStoriesRow(
              timelines: loaded.timelines,
              activeId: loaded.activeTimelineId,
              onTap: cubit.filterByTimeline,
            ),
          ),
          if (loaded.activeTimelineId != null)
            SliverToBoxAdapter(
              child: _TimelineActionBar(
                timeline: loaded.timelines.firstWhere((t) => t.id == loaded.activeTimelineId),
                onSettings: () => _openTimelineSettings(context, loaded.activeTimelineId!),
              ),
            ),
          SliverToBoxAdapter(
            child: _FeedHeader(timelineCount: loaded.timelines.length, momentCount: loaded.moments.length),
          ),
          if (loaded.moments.isEmpty)
            const SliverFillRemaining(hasScrollBody: false, child: _EmptyFeed())
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final item = feedItems[index];
                  if (item is _FeedMonthHeader) return _MonthHeader(label: item.label);
                  if (item is! _FeedMomentItem) return const SizedBox.shrink();
                  final moment = item.moment;
                  final timeline = timelineById[moment.timelineId];
                  if (timeline == null) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: BlocProvider<InteractionsBloc>(
                      key: ValueKey('interactions_${moment.id}'),
                      create: (_) => getIt<InteractionsBloc>()..add(InteractionsStarted(momentId: moment.id)),
                      child: NewMomentFeedCard(
                        moment: moment,
                        timeline: timeline,
                        currentUserEmail: loaded.currentUserEmail,
                        onWillNavigate: () {
                          _savedScrollOffset = _scrollController.hasClients ? _scrollController.offset : 0;
                        },
                      ),
                    ),
                  );
                }, childCount: feedItems.length),
              ),
            ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [_CreateTimelineCardFeed(), kSpacerHeight16, _HelpNote()],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Horizontal "stories"-style row to filter the feed by timeline.
class _TimelineStoriesRow extends StatelessWidget {
  const _TimelineStoriesRow({required this.timelines, required this.activeId, required this.onTap});

  final List<TimeLine> timelines;
  final String? activeId;
  final void Function(String?) onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return SizedBox(
      height: 90,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        children: [
          _StoryBubble(
            label: 'Todas',
            active: activeId == null,
            accent: palette.primary,
            coverUrl: '',
            isAll: true,
            onTap: () => onTap(null),
          ),
          ...timelines.map((timeline) {
            final accent = timeline.accentColor != null ? Color(timeline.accentColor!) : palette.primary;
            return _StoryBubble(
              label: timeline.name.isNotEmpty ? timeline.name : 'Linha',
              active: activeId == timeline.id,
              accent: accent,
              coverUrl: timeline.coverPhotoUrl,
              isAll: false,
              onTap: () => onTap(timeline.id),
            );
          }),
        ],
      ),
    );
  }
}

class _StoryBubble extends StatelessWidget {
  const _StoryBubble({
    required this.label,
    required this.active,
    required this.accent,
    required this.coverUrl,
    required this.isAll,
    required this.onTap,
  });

  final String label;
  final bool active;
  final Color accent;
  final String coverUrl;
  final bool isAll;
  final VoidCallback onTap;

  Widget _avatar(BuildContext context) {
    if (isAll) {
      return Container(
        decoration: BoxDecoration(color: accent.withValues(alpha: 0.15), shape: BoxShape.circle),
        alignment: Alignment.center,
        child: Icon(Icons.apps_rounded, color: accent, size: 24),
      );
    }
    if (coverUrl.isNotEmpty) {
      return ClipOval(
        child: AppNetworkImage(url: coverUrl, width: 52, height: 52, errorWidget: _initialAvatar(context)),
      );
    }
    return _initialAvatar(context);
  }

  Widget _initialAvatar(BuildContext context) {
    final initial = label.isNotEmpty ? label[0].toUpperCase() : '?';
    return Container(
      decoration: BoxDecoration(color: accent.withValues(alpha: 0.18), shape: BoxShape.circle),
      alignment: Alignment.center,
      child: Text(
        initial,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(color: accent, fontWeight: FontWeight.w700),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final palette = context.palette;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: SizedBox(
          width: 60,
          child: Column(
            children: [
              Container(
                width: 60,
                height: 60,
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: active
                      ? Border.all(color: accent, width: 2.5)
                      : Border.all(color: Colors.transparent, width: 2.5),
                ),
                child: SizedBox(width: 52, height: 52, child: _avatar(context)),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: textTheme.bodySmall?.copyWith(
                  color: active ? palette.onSurface : palette.onSurfaceMuted,
                  fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TimelineActionBar extends StatelessWidget {
  const _TimelineActionBar({required this.timeline, required this.onSettings});

  final TimeLine timeline;
  final VoidCallback onSettings;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final textTheme = Theme.of(context).textTheme;
    final accent = timeline.accentColor != null ? Color(timeline.accentColor!) : palette.primary;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
      child: InkWell(
        onTap: onSettings,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: accent.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: accent.withValues(alpha: 0.25)),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline_rounded, size: 16, color: accent),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Ver mais detalhes de "${timeline.name.isNotEmpty ? timeline.name : 'Linha'}"',
                  style: textTheme.bodySmall?.copyWith(color: accent, fontWeight: FontWeight.w500),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(Icons.chevron_right_rounded, size: 16, color: accent),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeedHeader extends StatelessWidget {
  const _FeedHeader({required this.timelineCount, required this.momentCount});

  final int timelineCount;
  final int momentCount;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final palette = context.palette;
    final timelineLabel = timelineCount == 1 ? '1 linha do tempo' : '$timelineCount linhas do tempo';
    final momentLabel = momentCount == 1 ? '1 momento' : '$momentCount momentos';
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Row(
        children: [
          Flexible(
            child: Text(
              '$timelineLabel · $momentLabel',
              style: textTheme.bodyMedium?.copyWith(color: palette.onSurfaceMuted),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyFeed extends StatelessWidget {
  const _EmptyFeed();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final palette = context.palette;
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(color: palette.primarySoft, shape: BoxShape.circle),
            child: Icon(Icons.photo_library_outlined, color: palette.primary, size: 40),
          ),
          kSpacerHeight16,
          Text('Nenhum momento encontrado', style: textTheme.titleMedium, textAlign: TextAlign.center),
          kSpacerHeight8,
          Text(
            'Registre um momento para começar a preencher o seu feed.',
            style: textTheme.bodyMedium?.copyWith(color: palette.onSurfaceMuted),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Bottom sheet to choose the timeline for a new moment (multi-timeline case).
class _TimelinePickerSheet extends StatelessWidget {
  const _TimelinePickerSheet({required this.timelines});

  final List<TimeLine> timelines;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final palette = context.palette;
    return Container(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + MediaQuery.of(context).viewInsets.bottom),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadii.card)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Em qual linha do tempo?', style: textTheme.titleLarge),
          kSpacerHeight8,
          Text(
            'Escolha onde registrar o novo momento.',
            style: textTheme.bodyMedium?.copyWith(color: palette.onSurfaceMuted),
          ),
          kSpacerHeight16,
          Flexible(
            child: ListView(
              shrinkWrap: true,
              children: timelines.map((timeline) {
                final accent = timeline.accentColor != null ? Color(timeline.accentColor!) : palette.primary;
                final name = timeline.name.isNotEmpty ? timeline.name : 'Nossa linha do tempo';
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(color: accent.withValues(alpha: 0.18), shape: BoxShape.circle),
                    alignment: Alignment.center,
                    child: Icon(Icons.favorite_rounded, color: accent, size: 20),
                  ),
                  title: Text(name, style: textTheme.titleSmall),
                  trailing: Icon(Icons.chevron_right_rounded, color: palette.onSurfaceMuted),
                  onTap: () => Navigator.of(context).pop(timeline),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

/// Gradient card that starts the create-timeline flow, reloading the feed after.
class _CreateTimelineCardFeed extends StatelessWidget {
  const _CreateTimelineCardFeed();

  Future<void> _onCreate(BuildContext context) async {
    final cubit = context.read<NewFeedCubit>();
    final navigator = Navigator.of(context);
    final policy = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _MomentEditPolicySheet(),
    );
    if (policy == null) return;
    await navigator.pushNamed(AppRoute.timeLine.tag, arguments: (timeLineId: null, momentEditPolicy: policy));
    cubit.load();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final palette = context.palette;

    return GestureDetector(
      onTap: () => _onCreate(context),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [palette.primary, palette.secondaryAccent]),
          borderRadius: BorderRadius.circular(AppRadii.card),
          boxShadow: AppShadows.soft(context),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
              child: Icon(Icons.add_rounded, color: palette.primary, size: 28),
            ),
            kSpacerWidth16,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Criar nova linha do tempo',
                    style: textTheme.titleMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Registre seus momentos e compartilhe com quem quiser.',
                    style: textTheme.bodySmall?.copyWith(color: Colors.white.withValues(alpha: 0.9)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Bottom sheet to pick how members may edit each other's moments when creating
/// a new timeline. Pops 'individual' | 'collaborative' or null when dismissed.
class _MomentEditPolicySheet extends StatefulWidget {
  const _MomentEditPolicySheet();

  @override
  State<_MomentEditPolicySheet> createState() => _MomentEditPolicySheetState();
}

class _MomentEditPolicySheetState extends State<_MomentEditPolicySheet> {
  String _policy = 'individual';

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final palette = context.palette;

    return Container(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + MediaQuery.of(context).viewInsets.bottom),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadii.card)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Nova linha do tempo', style: textTheme.titleLarge),
          kSpacerHeight8,
          Text(
            'Como vocês vão editar os momentos um do outro?',
            style: textTheme.bodyMedium?.copyWith(color: palette.onSurfaceMuted),
          ),
          kSpacerHeight16,
          _PolicyOption(
            title: 'Individual',
            subtitle: 'Cada pessoa só edita os momentos que criou.',
            icon: Icons.person_outline,
            value: 'individual',
            groupValue: _policy,
            onTap: () => setState(() => _policy = 'individual'),
          ),
          kSpacerHeight12,
          _PolicyOption(
            title: 'Colaborativa',
            subtitle: 'Qualquer editor pode editar os momentos de todos.',
            icon: Icons.groups_outlined,
            value: 'collaborative',
            groupValue: _policy,
            onTap: () => setState(() => _policy = 'collaborative'),
          ),
          kSpacerHeight24,
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () => Navigator.of(context).pop(_policy),
              child: const Text('Criar linha do tempo'),
            ),
          ),
        ],
      ),
    );
  }
}

class _PolicyOption extends StatelessWidget {
  const _PolicyOption({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.value,
    required this.groupValue,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final String value;
  final String groupValue;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final palette = context.palette;
    final selected = value == groupValue;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadii.input),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected ? palette.primarySoft : palette.surfaceAlt,
          borderRadius: BorderRadius.circular(AppRadii.input),
          border: Border.all(color: selected ? palette.primary : Colors.transparent, width: 1.5),
        ),
        child: Row(
          children: [
            Icon(icon, color: selected ? palette.primary : palette.onSurfaceMuted),
            kSpacerWidth12,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: textTheme.titleSmall),
                  const SizedBox(height: 2),
                  Text(subtitle, style: textTheme.bodySmall?.copyWith(color: palette.onSurfaceMuted)),
                ],
              ),
            ),
            if (selected) Icon(Icons.check_circle, color: palette.primary),
          ],
        ),
      ),
    );
  }
}

sealed class _FeedItem {}

class _FeedMonthHeader extends _FeedItem {
  _FeedMonthHeader(this.label);

  final String label;
}

class _FeedMomentItem extends _FeedItem {
  _FeedMomentItem(this.moment);

  final Moment moment;
}

class _MonthHeader extends StatelessWidget {
  const _MonthHeader({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 16, 0, 8),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: palette.onSurfaceMuted,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}

/// "Lost access?" support note.
class _HelpNote extends StatelessWidget {
  const _HelpNote();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final palette = context.palette;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: palette.surfaceAlt, borderRadius: BorderRadius.circular(AppRadii.input)),
      child: Row(
        children: [
          Icon(Icons.info_outline_rounded, size: 20, color: palette.onSurfaceMuted),
          kSpacerWidth12,
          Flexible(
            child: Text(
              'Perdeu acesso à sua linha do tempo? Fale com: contato.lutestudios@gmail.com',
              style: textTheme.bodySmall?.copyWith(color: palette.onSurfaceMuted),
            ),
          ),
        ],
      ),
    );
  }
}
