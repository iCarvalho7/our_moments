import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:nossos_momentos/di/injection.dart';
import 'package:nossos_momentos/modules/core/presenter/routes.dart';
import 'package:nossos_momentos/modules/core/presenter/widgets/app_card.dart';
import 'package:nossos_momentos/modules/core/presenter/widgets/background_gradient.dart';
import 'package:nossos_momentos/modules/core/presenter/widgets/app_network_image.dart';
import 'package:nossos_momentos/modules/core/presenter/widgets/loading_effect.dart';
import 'package:nossos_momentos/modules/core/presenter/widgets/primary_app_bar.dart';
import 'package:nossos_momentos/modules/core/utils/theme/app_theme.dart';
import 'package:nossos_momentos/modules/time_line/domain/entity/time_line.dart';
import 'package:nossos_momentos/modules/time_line/presenter/bloc/select_time_line_bloc.dart';
import 'package:nossos_momentos/modules/time_line/presenter/utils/relationship_duration.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SelectTimeLinePage extends StatefulWidget {
  const SelectTimeLinePage({super.key});

  @override
  State<SelectTimeLinePage> createState() => _SelectTimeLinePageState();
}

class _SelectTimeLinePageState extends State<SelectTimeLinePage> {
  List<TimeLine> _orderedTimelines = [];
  static const _kOrderKey = 'timeline_order';

  /// Reads the saved ID order from prefs, sorts [timelines] accordingly, and
  /// appends any new timelines (not yet in the saved list) at the end.
  Future<void> _loadAndApplyOrder(List<TimeLine> timelines) async {
    final prefs = await SharedPreferences.getInstance();
    final savedIds = prefs.getStringList(_kOrderKey);
    final byId = {for (final t in timelines) t.id: t};

    List<TimeLine> ordered;
    if (savedIds == null || savedIds.isEmpty) {
      ordered = List.of(timelines);
    } else {
      ordered = [for (final id in savedIds) if (byId.containsKey(id)) byId[id]!];
      final orderedIds = ordered.map((t) => t.id).toSet();
      ordered.addAll(timelines.where((t) => !orderedIds.contains(t.id)));
    }
    if (mounted) setState(() => _orderedTimelines = ordered);
  }

  Future<void> _saveOrder() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setStringList(_kOrderKey, _orderedTimelines.map((t) => t.id).toList());
  }

  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      // onReorderItem already accounts for the removed item; no index adjustment needed.
      final item = _orderedTimelines.removeAt(oldIndex);
      _orderedTimelines.insert(newIndex, item);
    });
    _saveOrder();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<SelectTimeLineBloc>()..add(SelectTimeLineEventFetchAll()),
      // Builder so the app bar's context is a descendant of the BlocProvider
      // (otherwise the "Sair" button can't read SelectTimeLineBloc).
      child: Builder(
        builder: (context) {
          return Stack(
            children: [
              const BackgroundGradient(),
              Scaffold(
                backgroundColor: Colors.transparent,
                appBar: PrimaryAppBar(
                  title: 'Histórias',
                  back: IconButton(
                    tooltip: 'Sair',
                    onPressed: () {
                      context.read<SelectTimeLineBloc>().add(SelectTimeLineEventLogout());
                    },
                    icon: const Icon(Icons.logout_rounded),
                  ),
                  icons: [
                    IconButton(
                      tooltip: 'Ver todos os momentos',
                      icon: const Icon(Icons.map_outlined),
                      onPressed: () => Navigator.of(context)
                          .pushNamed(AppRoute.allTimelinesMap.tag),
                    ),
                  ],
                ),
                body: SafeArea(
                  child: BlocConsumer<SelectTimeLineBloc, SelectTimeLineState>(
                    listener: _listener,
                    builder: (context, state) {
                      return RefreshIndicator(
                        onRefresh: () async {
                          context.read<SelectTimeLineBloc>().add(SelectTimeLineEventFetchAll());
                        },
                        child: _buildBody(context, state),
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, SelectTimeLineState state) {
    if (state is SelectTimeLineLoading) {
      final palette = context.palette;
      return ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        itemCount: 3,
        itemBuilder: (_, __) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: LoadingEffect(
            child: Container(
              height: 180,
              decoration: BoxDecoration(
                color: palette.surface,
                borderRadius: BorderRadius.circular(AppRadii.card),
              ),
            ),
          ),
        ),
      );
    }

    if (state is SelectTimeLineSuccess && state.timeLines.isNotEmpty) {
      return CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            sliver: SliverToBoxAdapter(
              child: _Intro(timelines: _orderedTimelines),
            ),
          ),
          SliverPadding(
            // Left reduced to 8 — the 24px track column makes total card offset 32px.
            padding: const EdgeInsets.only(left: 8, right: 16),
            sliver: SliverReorderableList(
              itemCount: _orderedTimelines.length,
              onReorderItem: _onReorder,
              itemBuilder: (context, index) {
                final item = _orderedTimelines[index];
                return ReorderableDelayedDragStartListener(
                  key: ValueKey(item.id),
                  index: index,
                  child: _TimelineTrackWrapper(
                    item: item,
                    isLast: index == _orderedTimelines.length - 1,
                  ),
                );
              },
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _CreateTimeLineCard(),
                  kSpacerHeight24,
                  const _HelpNote(),
                ],
              ),
            ),
          ),
        ],
      );
    }

    // Empty / error → onboarding to create the first timeline.
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        const _EmptyHero(),
        kSpacerHeight24,
        const _CreateTimeLineCard(),
        kSpacerHeight16,
        Text(
          'Para ver uma história existente, peça acesso a quem a criou.',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: context.palette.onSurfaceMuted,
              ),
        ),
        kSpacerHeight24,
        const _HelpNote(),
      ],
    );
  }

  void _listener(BuildContext context, SelectTimeLineState state) {
    if (state is SelectTimeLineSuccess && state.timeLines.isNotEmpty) {
      _loadAndApplyOrder(state.timeLines);
    }
    if (state is SelectTimeLogoutSuccess) {
      Navigator.of(context)
          .pushNamedAndRemoveUntil(AppRoute.login.tag, (Route<dynamic> route) => false);
    }
    if (state is SelectTimeLineError) {
      final msm = kDebugMode ? state.error : 'Erro ao criar sua história';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(backgroundColor: Colors.red, content: Text(msm)),
      );
    }
  }
}

/// Greeting line above the list.
class _Intro extends StatelessWidget {
  const _Intro({required this.timelines});

  final List<TimeLine> timelines;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final palette = context.palette;
    final count = timelines.length;
    final totalMoments = timelines.fold(0, (s, t) => s + t.momentIds.length);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Suas memórias', style: textTheme.headlineMedium),
        kSpacerHeight8,
        Row(
          children: [
            Text(
              count == 1 ? '1 história' : '$count histórias',
              style: textTheme.bodyMedium?.copyWith(color: palette.onSurfaceMuted),
            ),
            kSpacerWidth12,
            Container(width: 1, height: 12, color: palette.onSurfaceMuted.withValues(alpha: 0.4)),
            kSpacerWidth12,
            Text(
              '$totalMoments ${totalMoments == 1 ? 'momento' : 'momentos'}',
              style: textTheme.bodyMedium?.copyWith(color: palette.onSurfaceMuted),
            ),
          ],
        ),
      ],
    );
  }
}

/// Wraps a timeline card with a left-side visual track: a colored dot that
/// marks this entry on the timeline and a vertical connecting line to the next.
class _TimelineTrackWrapper extends StatelessWidget {
  const _TimelineTrackWrapper({required this.item, required this.isLast});

  final TimeLine item;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final accent = item.accentColor != null ? Color(item.accentColor!) : palette.primary;

    // IntrinsicHeight forces the Row to measure the card's real height first,
    // avoiding unconstrained-height issues when rendered inside a sliver.
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 24,
            child: Column(
              children: [
                const SizedBox(height: 26),
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: accent,
                    shape: BoxShape.circle,
                    border: Border.all(color: palette.surface, width: 2),
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Center(
                      child: Container(
                        width: 2,
                        color: palette.onSurfaceMuted.withValues(alpha: 0.2),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(child: _SelectTimeLineItem(item: item)),
        ],
      ),
    );
  }
}

class _SelectTimeLineItem extends StatelessWidget {
  const _SelectTimeLineItem({required this.item});

  final TimeLine item;

  String _membersLabel() {
    if (item.nicknames.isNotEmpty) {
      final names = item.emails
          .where((e) => item.nicknames.containsKey(e))
          .map((e) => item.nicknames[e]!)
          .take(2)
          .toList();
      if (names.length >= 2) return '${names[0]} & ${names[1]}';
      if (names.isNotEmpty) return names.first;
    }
    final parts = item.emails.take(2).map((e) {
      final local = e.split('@').first;
      return local.isEmpty ? e : '${local[0].toUpperCase()}${local.substring(1)}';
    }).toList();
    if (parts.length >= 2) return '${parts[0]} & ${parts[1]}';
    return parts.isNotEmpty ? parts.first : '';
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final palette = context.palette;
    final accent = item.accentColor != null ? Color(item.accentColor!) : palette.primary;
    final name = item.name.isNotEmpty ? item.name : 'Nossa história';
    final members = _membersLabel();
    final hasCover = item.coverPhotoUrl.isNotEmpty;

    void onTap() {
      final bloc = context.read<SelectTimeLineBloc>();
      Navigator.pushNamed(context, AppRoute.newSelectTimeLine.tag, arguments: item.id)
          .then((e) => bloc.add(SelectTimeLineEventFetchAll()));
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: AppCard(
        onTap: onTap,
        // Zero padding when cover is present; content area handles its own padding below.
        padding: hasCover ? EdgeInsets.zero : const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (hasCover)
              // Cover photo clipped to the card's top rounded corners.
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(AppRadii.card),
                  topRight: Radius.circular(AppRadii.card),
                ),
                child: _CoverPhotoHeader(
                  url: item.coverPhotoUrl,
                  accent: accent,
                  membersLabel: members,
                ),
              ),

            Padding(
              padding: hasCover
                  ? const EdgeInsets.fromLTRB(20, 16, 20, 20)
                  : EdgeInsets.zero,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header row — shows AccentTile + title + members when no cover,
                  // just title when cover already displays the members label.
                  if (!hasCover)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _AccentTile(color: accent),
                        kSpacerWidth16,
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: textTheme.titleLarge,
                              ),
                              if (members.isNotEmpty) ...[
                                const SizedBox(height: 3),
                                Text(
                                  members,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: textTheme.bodySmall
                                      ?.copyWith(color: palette.onSurfaceMuted),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    )
                  else
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.titleLarge,
                    ),

                  // Date / duration section
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 14),
                    child: Divider(height: 1),
                  ),
                  _DateDurationSection(item: item, accent: accent),

                  // Footer: avatars + CTA
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 14),
                    child: Divider(height: 1),
                  ),
                  Row(
                    children: [
                      _AvatarStack(emails: item.emails, color: accent),
                      const Spacer(),
                      Text(
                        'Ver os momentos',
                        style: textTheme.titleSmall?.copyWith(color: accent),
                      ),
                      Icon(Icons.chevron_right_rounded, color: accent),
                    ],
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

/// Full-bleed cover photo with a gradient and the couple's nickname overlaid.
class _CoverPhotoHeader extends StatelessWidget {
  const _CoverPhotoHeader({
    required this.url,
    required this.accent,
    required this.membersLabel,
  });

  final String url;
  final Color accent;
  final String membersLabel;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return SizedBox(
      height: 140,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          AppNetworkImage(
            url: url,
            fit: BoxFit.cover,
            height: 140,
            errorWidget: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [accent.withValues(alpha: 0.4), accent.withValues(alpha: 0.15)],
                ),
              ),
              child: Center(
                child: Icon(Icons.favorite_rounded, color: accent, size: 36),
              ),
            ),
          ),
          // Gradient so the nickname text is always readable.
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.60),
                ],
                stops: const [0.4, 1.0],
              ),
            ),
          ),
          if (membersLabel.isNotEmpty)
            Positioned(
              left: 16,
              right: 16,
              bottom: 14,
              child: Row(
                children: [
                  Icon(Icons.favorite_rounded, color: accent, size: 16),
                  kSpacerWidth8,
                  Expanded(
                    child: Text(
                      membersLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        shadows: const [Shadow(blurRadius: 4)],
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// Exibe o período do relacionamento, duração amigável e contagem de momentos.
class _DateDurationSection extends StatelessWidget {
  const _DateDurationSection({required this.item, required this.accent});

  final TimeLine item;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final palette = context.palette;
    final start = item.relationshipStartDate;
    final end = item.relationshipEndDate;
    final isEnded = end != null;
    final fmt = DateFormat("d 'de' MMM yyyy", 'pt_BR');

    // No dates configured yet — show moment count + creation date
    if (start == null) {
      return Row(
        children: [
          Icon(Icons.photo_library_outlined, size: 14, color: palette.onSurfaceMuted),
          kSpacerWidth8,
          Text(
            item.momentsAmount,
            style: textTheme.bodySmall?.copyWith(color: palette.onSurfaceMuted),
          ),
          kSpacerWidth12,
          Container(width: 1, height: 12, color: palette.onSurfaceMuted.withValues(alpha: 0.3)),
          kSpacerWidth12,
          Icon(Icons.calendar_today_outlined, size: 13, color: palette.onSurfaceMuted),
          kSpacerWidth8,
          Expanded(
            child: Text(
              'criada em ${fmt.format(item.createdDate.toDate())}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: textTheme.bodySmall?.copyWith(color: palette.onSurfaceMuted),
            ),
          ),
        ],
      );
    }

    final reference = isEnded ? end : DateTime.now();
    final duration = RelationshipDuration.friendly(start, now: reference);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Row 1: date range (left) + moment count (right)
        Row(
          children: [
            Icon(
              isEnded ? Icons.lock_outline_rounded : Icons.favorite_rounded,
              size: 14,
              color: isEnded ? palette.onSurfaceMuted : accent,
            ),
            kSpacerWidth8,
            Expanded(
              child: Row(
                children: [
                  Flexible(
                    child: Text(
                      fmt.format(start),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodySmall?.copyWith(
                        color: palette.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Icon(Icons.arrow_forward_rounded, size: 12, color: palette.onSurfaceMuted),
                  ),
                  Flexible(
                    child: Text(
                      isEnded ? fmt.format(end) : 'hoje',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodySmall?.copyWith(
                        color: isEnded ? palette.onSurfaceMuted : accent,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Icon(Icons.photo_library_outlined, size: 14, color: palette.onSurfaceMuted),
            const SizedBox(width: 5),
            Text(
              item.momentsAmount,
              style: textTheme.bodySmall?.copyWith(color: palette.onSurfaceMuted),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Row 2: duration badge sozinho — sem concorrência de espaço
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: isEnded ? palette.surfaceAlt : accent.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            isEnded ? '$duration de história' : '$duration juntos',
            style: textTheme.bodySmall?.copyWith(
              color: isEnded ? palette.onSurfaceMuted : accent,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

/// Rounded accent square with a heart, identifying a timeline by its color.
class _AccentTile extends StatelessWidget {
  const _AccentTile({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color, Color.lerp(color, Colors.white, 0.25) ?? color],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Icon(Icons.favorite_rounded, color: Colors.white, size: 26),
    );
  }
}

/// Overlapping initial-avatars for the people sharing a timeline.
class _AvatarStack extends StatelessWidget {
  const _AvatarStack({required this.emails, required this.color});

  final List<String> emails;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final shown = emails.take(3).toList();
    const size = 30.0;
    const overlap = 20.0;
    final extra = emails.length - shown.length;

    return SizedBox(
      height: size,
      width: shown.isEmpty ? 0 : size + (shown.length - 1) * overlap + (extra > 0 ? overlap : 0),
      child: Stack(
        children: [
          for (var i = 0; i < shown.length; i++)
            Positioned(
              left: i * overlap,
              child: _Avatar(
                letter: shown[i].isNotEmpty ? shown[i][0].toUpperCase() : '?',
                color: color,
              ),
            ),
          if (extra > 0)
            Positioned(
              left: shown.length * overlap,
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  color: palette.surfaceAlt,
                  shape: BoxShape.circle,
                  border: Border.all(color: palette.surface, width: 2),
                ),
                alignment: Alignment.center,
                child: Text(
                  '+$extra',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: palette.onSurfaceMuted,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.letter, required this.color});

  final String letter;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.18),
        shape: BoxShape.circle,
        border: Border.all(color: palette.surface, width: 2),
      ),
      alignment: Alignment.center,
      child: Text(
        letter,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}

/// Eye-catching gradient card that starts the create-timeline flow.
class _CreateTimeLineCard extends StatelessWidget {
  const _CreateTimeLineCard();

  Future<void> _onCreate(BuildContext context) async {
    final bloc = context.read<SelectTimeLineBloc>();
    final navigator = Navigator.of(context);
    final policy = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _MomentEditPolicySheet(),
    );
    if (policy == null) return;
    await navigator.pushNamed(
      AppRoute.newSelectTimeLine.tag,
      arguments: (timeLineId: null, momentEditPolicy: policy),
    );
    bloc.add(SelectTimeLineEventFetchAll());
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
                    'Criar nova história',
                    style: textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Registre seus momentos e compartilhe com quem quiser.',
                    style: textTheme.bodySmall?.copyWith(
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
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

/// Bottom sheet that lets the user pick how members may edit each other's
/// moments when creating a new timeline. Pops the chosen policy string
/// ('individual' | 'collaborative') or null when dismissed.
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
      padding: EdgeInsets.fromLTRB(
        20,
        20,
        20,
        20 + MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadii.card)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Nova história', style: textTheme.titleLarge),
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
              child: const Text('Criar história'),
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
          border: Border.all(
            color: selected ? palette.primary : Colors.transparent,
            width: 1.5,
          ),
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
                  Text(
                    subtitle,
                    style: textTheme.bodySmall?.copyWith(color: palette.onSurfaceMuted),
                  ),
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

/// Hero shown when the user has no timelines yet.
class _EmptyHero extends StatelessWidget {
  const _EmptyHero();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final palette = context.palette;
    return Padding(
      padding: const EdgeInsets.only(top: 24),
      child: Column(
        children: [
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(color: palette.primarySoft, shape: BoxShape.circle),
            child: Icon(Icons.favorite_rounded, color: palette.primary, size: 44),
          ),
          kSpacerHeight24,
          Text('Comece sua história', style: textTheme.headlineMedium, textAlign: TextAlign.center),
          kSpacerHeight8,
          Text(
            'Crie sua primeira história para guardar e reviver os momentos de vocês.',
            style: textTheme.bodyMedium?.copyWith(color: palette.onSurfaceMuted),
            textAlign: TextAlign.center,
          ),
        ],
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
      decoration: BoxDecoration(
        color: palette.surfaceAlt,
        borderRadius: BorderRadius.circular(AppRadii.input),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline_rounded, size: 20, color: palette.onSurfaceMuted),
          kSpacerWidth12,
          Flexible(
            child: Text(
              'Perdeu acesso à sua história? Fale com: contato.lutestudios@gmail.com',
              style: textTheme.bodySmall?.copyWith(color: palette.onSurfaceMuted),
            ),
          ),
        ],
      ),
    );
  }
}
