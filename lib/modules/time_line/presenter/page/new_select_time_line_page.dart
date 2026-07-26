import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nossos_momentos/di/injection.dart';
import 'package:nossos_momentos/modules/core/feature_toggles/feature_toggle_manager.dart';
import 'package:nossos_momentos/modules/core/presenter/routes.dart';
import 'package:nossos_momentos/modules/core/presenter/widgets/background_gradient.dart';
import 'package:nossos_momentos/modules/core/presenter/widgets/app_bottom_nav.dart';
import 'package:nossos_momentos/modules/core/presenter/widgets/app_network_image.dart';
import 'package:nossos_momentos/modules/core/presenter/widgets/custom_delete_dialog.dart';
import 'package:nossos_momentos/modules/core/presenter/widgets/loading_effect.dart';
import 'package:nossos_momentos/modules/core/presenter/widgets/primary_app_bar.dart';
import 'package:nossos_momentos/modules/core/presenter/widgets/primary_button.dart';
import 'package:nossos_momentos/modules/core/utils/theme/app_theme.dart';
import 'package:nossos_momentos/modules/moment/domain/entities/moment.dart';
import 'package:nossos_momentos/modules/moment/domain/entities/moment_type.dart';
import 'package:nossos_momentos/modules/moment/interactions/presenter/bloc/interactions_bloc.dart';
import 'package:nossos_momentos/modules/moment/presenter/bloc/add_or_edit_moment_bloc.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

import '../../domain/entity/time_line.dart';
import '../../domain/entity/timeline_permissions.dart';
import '../../gamification/domain/entity/momentum_progress.dart';
import '../bloc/new_feed_cubit.dart';
import '../bloc/time_line_bloc.dart';
import '../utils/relationship_duration.dart';
import '../widgets/memory_card.dart';
import '../widgets/new_moment_feed_card.dart';

sealed class _PageMode {}

class _AllTimelines extends _PageMode {}

class _SingleTimeline extends _PageMode {
  _SingleTimeline(this.bloc);

  final TimeLineBloc bloc;
}

/// Social-feed home with inline detail mode. Tapping a timeline story bubble
/// enters the full single-timeline view without a route change; the back button
/// returns to the aggregate feed.
class NewSelectTimeLinePage extends StatefulWidget {
  const NewSelectTimeLinePage({super.key});

  @override
  State<NewSelectTimeLinePage> createState() => _NewSelectTimeLinePageState();
}

class _NewSelectTimeLinePageState extends State<NewSelectTimeLinePage> {
  _PageMode _mode = _AllTimelines();
  bool _didHandleArgs = false;

  // Feed scroll state
  final _feedScrollController = ScrollController();
  double _feedScrollOffset = 0;

  // Client-side incremental rendering: the feed materializes a growing window of
  // the (already-fetched) moments and extends it as the user nears the end, so a
  // very large feed doesn't lay out every card up front. Server-side pagination
  // isn't possible today — moment dates are stored as non-sortable strings, so
  // orderBy+limit would need a schema/backfill migration.
  static const int _feedPageSize = 30;
  int _feedVisibleCount = _feedPageSize;
  bool _feedHasMore = false;

  // Detail mode state
  String _detailSearchQuery = '';
  MomentType? _detailTypeFilter;
  bool _detailShowFavoritesOnly = false;
  final _detailScrollController = ScrollController();
  double _detailScrollOffset = 0;
  final _detailSearchController = TextEditingController();
  String? _pendingFilterId;
  DateTime? _detailStartDate;
  DateTime? _detailEndDate;

  // Memoized feed grouping. Building the month-grouped feed (filter + header
  // insertion) and the gamification banner ran on every rebuild — including
  // rebuilds that don't touch the moments (scroll-offset saves, keyboard, etc.).
  // We cache the result keyed by the source list identity + active local
  // filters, so it's recomputed only when the underlying data actually changes.
  static final DateFormat _monthFormat = DateFormat('MMMM yyyy', 'pt_BR');
  Object? _feedCacheKey;
  ({List<Moment> filtered, List<_FeedItem> items})? _feedCache;

  Object? _streakCacheKey;
  Widget? _streakCache;

  ({List<Moment> filtered, List<_FeedItem> items}) _feedItemsFor(List<Moment> moments) {
    final key = Object.hash(
      identityHashCode(moments),
      _detailSearchQuery,
      _detailTypeFilter,
      _detailShowFavoritesOnly,
      _detailStartDate,
      _detailEndDate,
    );
    final cached = _feedCache;
    if (key == _feedCacheKey && cached != null) return cached;

    // New data or filters → restart the incremental window from the top.
    _feedVisibleCount = _feedPageSize;

    final filtered = _applyLocalFilters(moments);
    final items = <_FeedItem>[];
    String? lastKey;
    for (final moment in filtered) {
      final dt = moment.dateTime;
      final monthKey = '${dt.year}-${dt.month.toString().padLeft(2, '0')}';
      if (monthKey != lastKey) {
        final raw = _monthFormat.format(dt);
        items.add(_FeedMonthHeader(raw[0].toUpperCase() + raw.substring(1)));
        lastKey = monthKey;
      }
      items.add(_FeedMomentItem(moment));
    }
    final result = (filtered: filtered, items: items);
    _feedCacheKey = key;
    _feedCache = result;
    return result;
  }

  /// Memoizes the gamification banner so `MomentumProgress.from` (two O(n) passes
  /// plus an O(n log n) streak sort) doesn't run on every rebuild — only when the
  /// underlying moments or the active história change.
  Widget _streakBanner(
    BuildContext context, {
    required NewFeedLoaded loaded,
    required TimeLine? activeTimeline,
    required List<Moment> filteredMoments,
  }) {
    final key = Object.hash(
      identityHashCode(loaded.moments),
      identityHashCode(filteredMoments),
      activeTimeline?.id,
      loaded.currentUserEmail,
      loaded.timelines.length,
    );
    final cached = _streakCache;
    if (key == _streakCacheKey && cached != null) return cached;

    final banner = _buildStreakBanner(
      context,
      loaded: loaded,
      activeTimeline: activeTimeline,
      filteredMoments: filteredMoments,
    );
    _streakCacheKey = key;
    _streakCache = banner;
    return banner;
  }

  Object? _detailCacheKey;
  List<Object>? _detailItemsCache;

  /// Filters + date-groups the detail timeline once per data/filter change.
  /// The sort is O(n log n) and previously reran on every rebuild (scrolls,
  /// keyboard, unrelated setState). Keyed on the source list identity, the
  /// active filters, and today's date (group labels like "Hoje" are date-bound).
  List<Object> _detailGroupedItems(List<Moment> source) {
    final query = _detailSearchQuery.trim().toLowerCase();
    final today = DateTime.now();
    final key = Object.hash(
      identityHashCode(source),
      query,
      _detailTypeFilter,
      _detailShowFavoritesOnly,
      today.year,
      today.month,
      today.day,
    );
    final cached = _detailItemsCache;
    if (key == _detailCacheKey && cached != null) return cached;

    final filtered = source.where((m) {
      final matchesType = _detailTypeFilter == null || m.type == _detailTypeFilter;
      final matchesFavorite = !_detailShowFavoritesOnly || m.isFavorite;
      final matchesQuery =
          query.isEmpty || m.title.toLowerCase().contains(query) || m.body.toLowerCase().contains(query);
      return matchesType && matchesFavorite && matchesQuery;
    }).toList()
      ..sort((a, b) => b.dateTime.compareTo(a.dateTime));

    final orderedLabels = <String>[];
    final byLabel = <String, List<Moment>>{};
    for (final moment in filtered) {
      final label = _groupLabel(moment.dateTime, today);
      if (!byLabel.containsKey(label)) {
        byLabel[label] = [];
        orderedLabels.add(label);
      }
      byLabel[label]!.add(moment);
    }

    final items = <Object>[];
    for (final label in orderedLabels) {
      items.add((label: label, count: byLabel[label]!.length));
      items.addAll(byLabel[label]!);
    }
    _detailCacheKey = key;
    _detailItemsCache = items;
    return items;
  }

  @override
  void initState() {
    super.initState();
    _feedScrollController.addListener(_onFeedScroll);
  }

  /// Grows the rendered window as the user nears the end of the feed.
  void _onFeedScroll() {
    if (!_feedHasMore || !_feedScrollController.hasClients) return;
    final pos = _feedScrollController.position;
    if (pos.pixels >= pos.maxScrollExtent - 600) {
      setState(() => _feedVisibleCount += _feedPageSize);
    }
  }

  /// Trims the full grouped feed to the current window, preserving month headers
  /// and counting only moment cards toward [_feedVisibleCount]. Also records
  /// whether more moments remain (drives the load-more trigger and footer).
  List<_FeedItem> _windowFeedItems(List<_FeedItem> all) {
    var shown = 0;
    var cut = all.length;
    for (var i = 0; i < all.length; i++) {
      if (all[i] is _FeedMomentItem) {
        shown++;
        if (shown >= _feedVisibleCount) {
          cut = i + 1;
          break;
        }
      }
    }
    _feedHasMore = cut < all.length;
    return _feedHasMore ? all.sublist(0, cut) : all;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didHandleArgs) return;
    _didHandleArgs = true;
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is String) {
      _pendingFilterId = args;
    } else if (args is ({String? timeLineId, String momentEditPolicy})) {
      if (args.timeLineId != null) {
        _pendingFilterId = args.timeLineId;
      } else {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _enterDetailMode(null, momentEditPolicy: args.momentEditPolicy);
        });
      }
    }
  }

  @override
  void dispose() {
    _feedScrollController.dispose();
    _detailScrollController.dispose();
    _detailSearchController.dispose();
    final mode = _mode;
    if (mode is _SingleTimeline) mode.bloc.close();
    super.dispose();
  }

  void _enterDetailMode(String? timelineId, {String momentEditPolicy = 'individual'}) {
    final oldMode = _mode;
    if (oldMode is _SingleTimeline) oldMode.bloc.close();
    final bloc = getIt<TimeLineBloc>()
      ..add(TimeLineEventInit(timeLineId: timelineId, momentEditPolicy: momentEditPolicy));
    setState(() {
      _mode = _SingleTimeline(bloc);
      _detailSearchQuery = '';
      _detailTypeFilter = null;
      _detailShowFavoritesOnly = false;
      _detailScrollOffset = 0;
      _detailSearchController.clear();
    });
  }

  void _exitDetailMode(BuildContext context) {
    final mode = _mode;
    if (mode is _SingleTimeline) mode.bloc.close();
    setState(() => _mode = _AllTimelines());
    context.read<NewFeedCubit>().load();
  }

  void _scrollFeedToTop() {
    if (_feedScrollController.hasClients) {
      _feedScrollController.animateTo(0, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    }
  }

  // ── Feed mode ────────────────────────────────────────────────────────────

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
    Navigator.pushNamed(
      context,
      AppRoute.momentsMap.tag,
    ).then((_) => context.mounted ? context.read<NewFeedCubit>().load() : null);
  }

  void _openAdd(BuildContext context, TimeLine timeline) {
    final cubit = context.read<NewFeedCubit>();
    _feedScrollOffset = _feedScrollController.hasClients ? _feedScrollController.offset : 0;
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

  // ── Detail mode ──────────────────────────────────────────────────────────

  String _detailTitle(BuildContext context, TimeLineState state) {
    if (state is TimeLineStateLoaded || state is TimeLineStateEmpty) {
      final name = context.read<TimeLineBloc>().timeLine.name;
      if (name.isNotEmpty) return name;
    }
    return Strings.appName;
  }

  Widget _buildDetailBottomNav(BuildContext context) {
    return AppBottomNav(
      items: [
        AppNavItem(icon: Icons.auto_awesome_outlined, label: 'Neste dia', onTap: () => _openOnThisDayFromNav(context)),
        AppNavItem(
          navKey: const ValueKey('key_timeline_nav_create'),
          icon: Icons.add_rounded,
          label: 'Adicionar',
          primary: true,
          onTap: () => _goToAddMoment(context),
        ),
        AppNavItem(
          navKey: const ValueKey('key_timeline_nav_settings'),
          icon: Icons.settings_outlined,
          label: 'Ajustes',
          onTap: () => _goToSettings(context, context.read<TimeLineBloc>().timeLine),
        ),
      ],
    );
  }

  void _openOnThisDayFromNav(BuildContext context) {
    final now = DateTime.now();
    final all = context.read<TimeLineBloc>().allMoments;
    final monthName = DateFormat.MMMM('pt_BR').format(now);

    final exact = all
        .where((m) => m.dateTime.month == now.month && m.dateTime.day == now.day && m.dateTime.year < now.year)
        .toList();
    if (exact.isNotEmpty) {
      _openOnThisDay(context, exact, scopeLabel: '${now.day} de $monthName');
      return;
    }

    final monthly = all.where((m) => m.dateTime.month == now.month && m.dateTime.year < now.year).toList();
    _openOnThisDay(context, monthly, scopeLabel: monthName);
  }

  Future<void> _goToSettings(BuildContext context, TimeLine timeLine) async {
    final bloc = context.read<TimeLineBloc>();
    await Navigator.pushNamed(context, AppRoute.settings.tag, arguments: timeLine.id);
    bloc.add(const TimeLineEventReloadTimeline());
  }

  Widget _buildOnThisDayBanner(BuildContext context) {
    final now = DateTime.now();
    final onThisDay = context
        .read<TimeLineBloc>()
        .allMoments
        .where((m) => m.dateTime.month == now.month && m.dateTime.day == now.day && m.dateTime.year < now.year)
        .toList();

    if (onThisDay.isEmpty) return const SizedBox.shrink();

    final palette = context.palette;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      child: GestureDetector(
        onTap: () =>
            _openOnThisDay(context, onThisDay, scopeLabel: '${now.day} de ${DateFormat.MMMM('pt_BR').format(now)}'),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: palette.primarySoft,
            borderRadius: BorderRadius.circular(AppRadii.card),
            border: Border.all(color: palette.primary.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              Icon(Icons.auto_awesome_rounded, color: palette.primary, size: 20),
              kSpacerWidth12,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Neste dia',
                      style: textTheme.titleSmall?.copyWith(color: palette.primary, fontWeight: FontWeight.w700),
                    ),
                    Text(
                      onThisDay.length == 1 ? '1 memória de outro ano' : '${onThisDay.length} memórias de outros anos',
                      style: textTheme.bodySmall?.copyWith(color: palette.onSurfaceMuted),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: palette.primary),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openOnThisDay(BuildContext context, List<Moment> moments, {String? scopeLabel}) async {
    final selected =
        await Navigator.of(
              context,
            ).pushNamed(AppRoute.onThisDay.tag, arguments: (moments: moments, scopeLabel: scopeLabel))
            as Moment?;
    if (selected != null && context.mounted) {
      _openMoment(context, selected);
    }
  }

  Widget _buildTogetherCounter(BuildContext context) {
    final palette = context.palette;
    final textTheme = Theme.of(context).textTheme;
    final timeLine = context.read<TimeLineBloc>().timeLine;
    final startDate = timeLine.relationshipStartDate;
    final endDate = timeLine.relationshipEndDate;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 2),
      child: GestureDetector(
        key: const ValueKey('key_timeline_start_date_button'),
        onTap: () => _pickRelationshipDate(context, startDate),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [palette.primary, palette.secondaryAccent]),
            borderRadius: BorderRadius.circular(AppRadii.card),
            boxShadow: AppShadows.soft(context),
          ),
          child: Row(
            children: [
              const Icon(Icons.favorite_rounded, color: Colors.white),
              kSpacerWidth12,
              Expanded(
                child: startDate == null
                    ? Text(
                        'Definir início do relacionamento',
                        style: textTheme.titleMedium?.copyWith(color: Colors.white),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            endDate == null ? 'Juntos há' : 'Ficaram juntos por',
                            style: textTheme.bodySmall?.copyWith(color: Colors.white.withValues(alpha: 0.85)),
                          ),
                          Text(
                            RelationshipDuration.friendly(startDate, now: endDate),
                            style: textTheme.titleMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
              ),
              Icon(startDate == null ? Icons.add_rounded : Icons.edit_calendar_outlined, color: Colors.white, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  void _pickRelationshipDate(BuildContext context, DateTime? current) {
    final bloc = context.read<TimeLineBloc>();
    showDatePicker(
      context: context,
      initialDate: current ?? DateTime.now(),
      firstDate: DateTime(1990),
      lastDate: DateTime.now(),
    ).then((date) {
      if (date != null) bloc.add(TimeLineEventSetRelationshipDate(date: date));
    });
  }

  Widget _buildDetailControls(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: TextField(
            controller: _detailSearchController,
            onChanged: (value) => setState(() => _detailSearchQuery = value),
            textInputAction: TextInputAction.search,
            decoration: const InputDecoration(hintText: 'Buscar momentos...', prefixIcon: Icon(Icons.search_rounded)),
          ),
        ),
        SizedBox(
          height: 38,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              _favoritesChip(context),
              _typeChip(context, null, 'Todos'),
              ...MomentType.values.map((type) => _typeChip(context, type, type.label)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _favoritesChip(BuildContext context) {
    final palette = context.palette;
    final selected = _detailShowFavoritesOnly;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () => setState(() {
          _detailShowFavoritesOnly = !_detailShowFavoritesOnly;
          if (_detailShowFavoritesOnly) _detailTypeFilter = null;
        }),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: selected ? palette.primary.withValues(alpha: 0.16) : palette.surfaceAlt,
            borderRadius: BorderRadius.circular(AppRadii.pill),
            border: Border.all(color: selected ? palette.primary.withValues(alpha: 0.5) : Colors.transparent),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                selected ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                size: 16,
                color: selected ? palette.primary : palette.onSurfaceMuted,
              ),
              kSpacerWidth8,
              Text(
                'Favoritos',
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(color: selected ? palette.onSurface : palette.onSurfaceMuted),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _typeChip(BuildContext context, MomentType? type, String label) {
    final palette = context.palette;
    final selected = type != null && _detailTypeFilter == type && !_detailShowFavoritesOnly;
    final accent = type?.colors(context).accent ?? palette.primary;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () => setState(() {
          _detailTypeFilter = selected ? null : type;
          _detailShowFavoritesOnly = false;
        }),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: selected ? accent.withValues(alpha: 0.16) : palette.surfaceAlt,
            borderRadius: BorderRadius.circular(AppRadii.pill),
            border: Border.all(color: selected ? accent.withValues(alpha: 0.5) : Colors.transparent),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (type != null) ...[
                Icon(type.icon, size: 16, color: selected ? accent : palette.onSurfaceMuted),
                kSpacerWidth8,
              ],
              Text(
                label,
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(color: selected ? palette.onSurface : palette.onSurfaceMuted),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _goToAddMoment(BuildContext context) {
    final timeLineBloc = context.read<TimeLineBloc>();
    final currentEmail = timeLineBloc.currentUserEmail;
    if (!TimelinePermissions.canEdit(timeLineBloc.timeLine, currentEmail)) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text('Você tem permissão de visualização — não pode criar momentos.')));
      return;
    }
    Navigator.pushNamed(
      context,
      AppRoute.addMoment.tag,
      arguments: (
        accentColor: timeLineBloc.timeLine.accentColor,
        endDate: timeLineBloc.timeLine.enforceEndDate ? timeLineBloc.timeLine.relationshipEndDate : null,
      ),
    ).then((saved) {
      if (saved == true) timeLineBloc.add(TimeLineEventChangeDate());
    });
    BlocProvider.of<AddOrEditMomentBloc>(context).add(SetupAddMomentEvent(timelineId: timeLineBloc.timelineId));
  }

  void _showDatePicker(BuildContext context, TimeLineState state) {
    final bloc = context.read<TimeLineBloc>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _DateFilterSheet(
        startDate: state.startDate,
        endDate: state.endDate,
        momentDates: bloc.momentDates,
        onApply: (start, end) => bloc.add(TimeLineEventChangeDate(startDate: start, endDate: end)),
      ),
    );
  }

  Widget _buildDetailScrollBody(BuildContext context, TimeLineState state) {
    return CustomScrollView(
      controller: _detailScrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: Column(
            children: [
              _buildDateRangeChip(context, state),
              _buildOnThisDayBanner(context),
              _buildTogetherCounter(context),
              kSpacerHeight8,
            ],
          ),
        ),
        SliverToBoxAdapter(child: _buildDetailControls(context)),
        ..._buildDetailFeedSlivers(context, state),
      ],
    );
  }

  Widget _buildDateRangeChip(BuildContext context, TimeLineState state) {
    final palette = context.palette;
    final textTheme = Theme.of(context).textTheme;
    final range = state.startDate == TimeLineBloc.kAllTimeStart
        ? 'Tudo'
        : '${DateFormat('dd/MM/yyyy').format(state.startDate)}  —  ${DateFormat('dd/MM/yyyy').format(state.endDate)}';

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      child: GestureDetector(
        onTap: () => _showDatePicker(context, state),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(color: palette.surfaceAlt, borderRadius: BorderRadius.circular(AppRadii.pill)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.calendar_today_rounded, size: 15, color: palette.onSurfaceMuted),
              kSpacerWidth8,
              Text(
                range,
                style: textTheme.bodySmall?.copyWith(color: palette.onSurface, fontWeight: FontWeight.w600),
              ),
              kSpacerWidth8,
              Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: palette.onSurfaceMuted),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildDetailFeedSlivers(BuildContext context, TimeLineState state) {
    final source = state is TimeLineStateLoaded ? state.momentsList : const <Moment>[];
    final hasFilters =
        _detailSearchQuery.trim().isNotEmpty || _detailTypeFilter != null || _detailShowFavoritesOnly;
    final items = _detailGroupedItems(source);

    if (items.isEmpty) {
      return [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  hasFilters ? Icons.search_off_rounded : Icons.auto_awesome_outlined,
                  size: 48,
                  color: context.palette.onSurfaceMuted,
                ),
                kSpacerHeight16,
                Text(
                  hasFilters ? 'Nenhum momento encontrado' : 'Nenhum momento nessa data ainda',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                kSpacerHeight8,
                Text(
                  hasFilters ? 'Tente outra busca ou filtro.' : 'Toque em + para registrar o primeiro.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: context.palette.onSurfaceMuted),
                ),
              ],
            ),
          ),
        ),
      ];
    }

    return [
      SliverPadding(
        padding: const EdgeInsets.only(bottom: 16),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate((ctx, index) {
            final item = items[index];
            if (item is Moment) {
              final bloc = ctx.read<TimeLineBloc>();
              return Dismissible(
                key: ValueKey(item.id),
                direction: DismissDirection.endToStart,
                confirmDismiss: (_) async {
                  if (!TimelinePermissions.canDeleteMoment(
                    ctx.read<TimeLineBloc>().timeLine,
                    item,
                    bloc.currentUserEmail,
                  )) {
                    ScaffoldMessenger.of(ctx)
                      ..hideCurrentSnackBar()
                      ..showSnackBar(
                        const SnackBar(
                          content: Text('Você tem permissão de visualização — não pode remover momentos.'),
                        ),
                      );
                    return false;
                  }
                  return CustomDeleteDialog.confirm(
                    ctx,
                    text: 'Você tem certeza que deseja remover esse momento das areias do tempo?',
                  );
                },
                onDismissed: (_) => bloc.add(TimeLineEventDeleteMoment(momentId: item.id)),
                background: const _SwipeDeleteBackground(alignment: Alignment.centerRight),
                child: GestureDetector(
                  onTap: () => _openMoment(ctx, item),
                  child: MemoryCard(
                    moment: item,
                    nicknames: bloc.timeLine.nicknames,
                    currentUserEmail: bloc.currentUserEmail,
                    onFavoriteToggle: () => bloc.add(TimeLineEventToggleFavorite(moment: item)),
                  ),
                ),
              );
            }
            final header = item as ({String label, int count});
            return _DateHeader(label: header.label, count: header.count);
          }, childCount: items.length),
        ),
      ),
    ];
  }

  String _groupLabel(DateTime date, DateTime now) {
    final d = DateTime(date.year, date.month, date.day);
    final today = DateTime(now.year, now.month, now.day);
    final diff = today.difference(d).inDays;
    if (diff == 0) return 'Hoje';
    if (diff == 1) return 'Ontem';
    if (diff >= 2 && diff <= 6) return 'Esta semana';
    if (d.year == today.year && d.month == today.month) return 'Este mês';
    final month = DateFormat.MMMM('pt_BR').format(d);
    final capitalized = '${month[0].toUpperCase()}${month.substring(1)}';
    return d.year == today.year ? capitalized : '$capitalized de ${d.year}';
  }

  Future<void> _openCoupleFeaturesHub(BuildContext context) async {
    final bloc = context.read<TimeLineBloc>();
    final unlocked =
        await Navigator.of(
              context,
            ).pushNamed(AppRoute.coupleFeaturesHub.tag, arguments: (moments: bloc.allMoments, timeLine: bloc.timeLine))
            as bool?;
    if (unlocked == true) bloc.add(TimeLineEventReloadTimeline());
  }

  void _openMoment(BuildContext context, Moment moment) {
    _detailScrollOffset = _detailScrollController.hasClients ? _detailScrollController.offset : 0;
    final timeLineBloc = context.read<TimeLineBloc>();
    Navigator.pushNamed(
      context,
      AppRoute.addMoment.tag,
      arguments: (
        accentColor: timeLineBloc.timeLine.accentColor,
        endDate: timeLineBloc.timeLine.enforceEndDate ? timeLineBloc.timeLine.relationshipEndDate : null,
      ),
    ).then((saved) {
      if (saved == true) timeLineBloc.add(TimeLineEventChangeDate());
    });
    BlocProvider.of<AddOrEditMomentBloc>(context).add(SetupEditMomentEvent(moment: moment));
  }

  Widget _buildDetailLoadingState() {
    return Column(
      children: [
        ListView.builder(
          itemCount: 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) => LoadingEffect(
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: 160,
              margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              decoration: BoxDecoration(
                color: context.palette.surface,
                borderRadius: BorderRadius.circular(AppRadii.card),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── Inline feed helpers ─────────────────────────────────────────────────

  void _resetInlineFilters() {
    _detailSearchQuery = '';
    _detailTypeFilter = null;
    _detailShowFavoritesOnly = false;
    _detailStartDate = null;
    _detailEndDate = null;
    _detailSearchController.clear();
  }

  List<Moment> _applyLocalFilters(List<Moment> moments) {
    final query = _detailSearchQuery.trim().toLowerCase();
    return moments.where((m) {
      if (_detailTypeFilter != null && m.type != _detailTypeFilter) return false;
      if (_detailShowFavoritesOnly && !m.isFavorite) return false;
      if (query.isNotEmpty && !m.title.toLowerCase().contains(query) && !m.body.toLowerCase().contains(query)) {
        return false;
      }
      if (_detailStartDate != null && m.dateTime.isBefore(_detailStartDate!)) return false;
      if (_detailEndDate != null && m.dateTime.isAfter(_detailEndDate!)) return false;
      return true;
    }).toList();
  }

  Widget _buildInlineTogetherCard(BuildContext context, TimeLine timeLine) {
    final startDate = timeLine.relationshipStartDate;
    final endDate = timeLine.relationshipEndDate;
    final palette = context.palette;
    final textTheme = Theme.of(context).textTheme;
    final cubit = context.read<NewFeedCubit>();
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 2),
      child: GestureDetector(
        key: const ValueKey('key_timeline_start_date_button'),
        onTap: () => Navigator.pushNamed(
          context,
          AppRoute.settings.tag,
          arguments: timeLine.id,
        ).then((_) => context.mounted ? cubit.load() : null),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [palette.primary, palette.secondaryAccent]),
            borderRadius: BorderRadius.circular(AppRadii.card),
            boxShadow: AppShadows.soft(context),
          ),
          child: Row(
            children: [
              const Icon(Icons.favorite_rounded, color: Colors.white),
              kSpacerWidth12,
              Expanded(
                child: startDate == null
                    ? Text(
                        'Definir início do relacionamento',
                        style: textTheme.titleMedium?.copyWith(color: Colors.white),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            endDate == null ? 'Juntos há' : 'Ficaram juntos por',
                            style: textTheme.bodySmall?.copyWith(color: Colors.white.withValues(alpha: 0.85)),
                          ),
                          Text(
                            RelationshipDuration.friendly(startDate, now: endDate),
                            style: textTheme.titleMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
              ),
              Icon(
                startDate == null ? Icons.settings_outlined : Icons.edit_calendar_outlined,
                color: Colors.white,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInlineDateChip(BuildContext context, List<Moment> timelineMoments) {
    final palette = context.palette;
    final textTheme = Theme.of(context).textTheme;
    final range = _detailStartDate == null
        ? 'Tudo'
        : '${DateFormat('dd/MM/yyyy').format(_detailStartDate!)}  —  ${DateFormat('dd/MM/yyyy').format(_detailEndDate!)}';
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      child: GestureDetector(
        onTap: () => _showInlineDatePicker(context, timelineMoments),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(color: palette.surfaceAlt, borderRadius: BorderRadius.circular(AppRadii.pill)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.calendar_today_rounded, size: 15, color: palette.onSurfaceMuted),
              kSpacerWidth8,
              Text(
                range,
                style: textTheme.bodySmall?.copyWith(color: palette.onSurface, fontWeight: FontWeight.w600),
              ),
              kSpacerWidth8,
              Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: palette.onSurfaceMuted),
            ],
          ),
        ),
      ),
    );
  }

  void _showInlineDatePicker(BuildContext context, List<Moment> moments) {
    final momentDates = moments.map((m) => m.dateTime).toList();
    final now = DateTime.now();
    final start = _detailStartDate ?? DateTime(now.year - 100, now.month, now.day);
    final end = _detailEndDate ?? now;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _DateFilterSheet(
        startDate: start,
        endDate: end,
        momentDates: momentDates,
        onApply: (s, e) => setState(() {
          final isAll = s.year < now.year - 50;
          _detailStartDate = isAll ? null : s;
          _detailEndDate = isAll ? null : e;
        }),
      ),
    );
  }

  // ── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<NewFeedCubit>()..load(),
      child: Builder(
        builder: (feedContext) {
          final mode = _mode;
          if (mode is _SingleTimeline) return _buildDetailMode(feedContext, mode);
          return _buildFeedMode(feedContext);
        },
      ),
    );
  }

  Widget _buildFeedMode(BuildContext context) {
    // The feed is the home screen after login. Back must never pop the route
    // (it would surface the login page underneath, depending on how the timeline
    // was reached); instead it backgrounds/exits the app like a normal home.
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) SystemNavigator.pop();
      },
      child: Stack(
        children: [
          const BackgroundGradient(),
          Scaffold(
            backgroundColor: Colors.transparent,
            appBar: const PrimaryAppBar(title: 'Nossos Momentos'),
          body: SafeArea(
            child: BlocConsumer<NewFeedCubit, NewFeedState>(
              listener: (context, state) {
                if (state is NewFeedLoaded && _feedScrollOffset > 0) {
                  final offset = _feedScrollOffset;
                  _feedScrollOffset = 0;
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (_feedScrollController.hasClients) {
                      _feedScrollController.jumpTo(offset.clamp(0.0, _feedScrollController.position.maxScrollExtent));
                    }
                  });
                }
              },
              builder: _buildFeedBody,
            ),
            ),
            bottomNavigationBar: AppBottomNav(
              items: [
                AppNavItem(
                  navKey: const ValueKey('key_bottom_nav_home'),
                icon: Icons.home_rounded,
                label: 'Início',
                selected: true,
                onTap: _scrollFeedToTop,
              ),
              AppNavItem(
                navKey: const ValueKey('key_bottom_nav_map'),
                icon: Icons.timeline_rounded,
                label: 'Mapa',
                onTap: () => _openTimeline(context),
              ),
              AppNavItem(
                navKey: const ValueKey('key_bottom_nav_create'),
                icon: Icons.add_rounded,
                label: 'Adicionar',
                primary: true,
                onTap: () => _onCreate(context),
              ),
              AppNavItem(
                navKey: const ValueKey('key_bottom_nav_moments'),
                icon: Icons.travel_explore_rounded,
                label: 'Momentos',
                onTap: () => Navigator.pushNamed(context, AppRoute.allTimelinesMap.tag),
              ),
              AppNavItem(
                navKey: const ValueKey('key_bottom_nav_settings'),
                icon: Icons.account_circle,
                label: 'Minha Conta',
                onTap: () => Navigator.pushNamed(context, AppRoute.accountSettings.tag),
              ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailMode(BuildContext feedContext, _SingleTimeline mode) {
    return BlocProvider.value(
      value: mode.bloc,
      child: BlocListener<TimeLineBloc, TimeLineState>(
        listener: (ctx, state) {
          if (state is TimeLineStateLoaded && _detailScrollOffset > 0) {
            final offset = _detailScrollOffset;
            _detailScrollOffset = 0;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (_detailScrollController.hasClients) {
                _detailScrollController.jumpTo(offset.clamp(0.0, _detailScrollController.position.maxScrollExtent));
              }
            });
          }
        },
        child: BlocBuilder<TimeLineBloc, TimeLineState>(
          builder: (ctx, state) {
            final accentValue = (state is TimeLineStateLoaded || state is TimeLineStateEmpty)
                ? ctx.read<TimeLineBloc>().timeLine.accentColor
                : null;
            return AccentScope(
              accentColor: accentValue,
              child: Builder(
                builder: (ctx2) {
                  return PopScope(
                    canPop: false,
                    onPopInvokedWithResult: (didPop, _) {
                      if (!didPop) _exitDetailMode(ctx2);
                    },
                    child: Stack(
                      children: [
                        Scaffold(
                          appBar: PrimaryAppBar(
                            title: _detailTitle(ctx2, state),
                            background: BackgroundGradient(),
                            back: IconButton(
                              icon: const Icon(Icons.arrow_back_rounded),
                              onPressed: () => _exitDetailMode(ctx2),
                            ),
                            icons: (state is TimeLineStateLoaded || state is TimeLineStateEmpty)
                                ? [
                                    IconButton(
                                      tooltip: 'Recursos do grupo',
                                      icon: const Icon(Icons.auto_awesome_mosaic_outlined),
                                      onPressed: () => _openCoupleFeaturesHub(ctx2),
                                    ),
                                  ]
                                : null,
                          ),
                          body: (state is TimeLineStateLoaded || state is TimeLineStateEmpty)
                              ? _buildDetailScrollBody(ctx2, state)
                              : _buildDetailLoadingState(),
                          bottomNavigationBar: (state is TimeLineStateLoaded || state is TimeLineStateEmpty)
                              ? _buildDetailBottomNav(ctx2)
                              : null,
                        ),
                      ],
                    ),
                  );
                },
              ),
            );
          },
        ),
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

    // Apply pending filter from route arguments (set in didChangeDependencies)
    if (_pendingFilterId != null) {
      final id = _pendingFilterId!;
      _pendingFilterId = null;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) context.read<NewFeedCubit>().filterByTimeline(id);
      });
    }

    final activeTimeline = loaded.activeTimelineId != null
        ? loaded.timelines.where((t) => t.id == loaded.activeTimelineId).firstOrNull
        : null;

    final feed = _feedItemsFor(loaded.moments);
    final filteredMoments = feed.filtered;
    final feedItems = _windowFeedItems(feed.items);

    return RefreshIndicator(
      onRefresh: () => cubit.load(),
      child: CustomScrollView(
        controller: _feedScrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: _TimelineStoriesRow(
              timelines: loaded.timelines,
              activeId: loaded.activeTimelineId,
              onTap: (id) {
                setState(() => _resetInlineFilters());
                cubit.filterByTimeline(id);
              },
            ),
          ),
          if (activeTimeline != null) ...[
            SliverToBoxAdapter(
              child: _ActiveTimelineBanner(
                timeline: activeTimeline,
                onOpen: () => Navigator.pushNamed(
                  context,
                  AppRoute.settings.tag,
                  arguments: activeTimeline.id,
                ).then((_) => context.mounted ? cubit.load() : null),
              ),
            ),
            SliverToBoxAdapter(child: _buildInlineTogetherCard(context, activeTimeline)),
          ],
          SliverToBoxAdapter(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [_buildInlineDateChip(context, loaded.moments), _buildDetailControls(context)],
            ),
          ),
          if (getIt<FeatureToggleManager>().isEnabled(AppFeatureToggle.gamification) &&
              filteredMoments.isNotEmpty)
            SliverToBoxAdapter(
              child: _streakBanner(
                context,
                loaded: loaded,
                activeTimeline: activeTimeline,
                filteredMoments: filteredMoments,
              ),
            ),
          SliverToBoxAdapter(
            child: _FeedHeader(timelineCount: loaded.timelines.length, momentCount: filteredMoments.length),
          ),
          if (loaded.timelines.isEmpty)
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              sliver: SliverToBoxAdapter(
                child: _CreateTimelineCardFeed(
                  onCreateTimeline: (policy) => _enterDetailMode(null, momentEditPolicy: policy),
                ),
              ),
            ),
          if (filteredMoments.isEmpty)
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
                          _feedScrollOffset = _feedScrollController.hasClients ? _feedScrollController.offset : 0;
                        },
                      ),
                    ),
                  );
                }, childCount: feedItems.length),
              ),
            ),
          if (_feedHasMore)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Center(child: CircularProgressIndicator()),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _CreateTimelineCardFeed(
                      onCreateTimeline: (policy) => _enterDetailMode(null, momentEditPolicy: policy),
                    ),
                    kSpacerHeight16,
                    const _HelpNote(),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ── Gamification streak banner ───────────────────────────────────────────────

/// Builds the feed's gamification banner contextually: with no timeline filter
/// it shows the user's **personal** aggregate (across every história) and opens
/// their profile; filtered to one história it shows that história's progress and
/// opens its achievements.
Widget _buildStreakBanner(
  BuildContext context, {
  required NewFeedLoaded loaded,
  required TimeLine? activeTimeline,
  required List<Moment> filteredMoments,
}) {
  if (activeTimeline == null) {
    final myMoments =
        loaded.moments.where((m) => m.author == loaded.currentUserEmail).toList();
    final progress = MomentumProgress.from(
      myMoments,
      distinctTimelines: loaded.timelines.length,
    );
    return _FeedStreakBanner(
      progress: progress,
      personal: true,
      onTap: () => Navigator.pushNamed(
        context,
        AppRoute.personalProfile.tag,
        arguments: (moments: myMoments, timelineCount: loaded.timelines.length),
      ),
    );
  }

  final progress = MomentumProgress.from(
    filteredMoments,
    relationshipStart: activeTimeline.relationshipStartDate,
  );
  return _FeedStreakBanner(
    progress: progress,
    personal: false,
    onTap: () => Navigator.pushNamed(
      context,
      AppRoute.achievements.tag,
      arguments: (moments: filteredMoments, timeLine: activeTimeline),
    ),
  );
}

/// Compact banner over the feed showing a level + current streak, tapping
/// through to the personal profile or the história's achievements.
class _FeedStreakBanner extends StatelessWidget {
  const _FeedStreakBanner({
    required this.progress,
    required this.personal,
    this.onTap,
  });

  final MomentumProgress progress;

  /// True when showing the user's aggregate identity (no timeline filter).
  final bool personal;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final textTheme = Theme.of(context).textTheme;
    final hasStreak = progress.currentStreakDays > 0;
    final days = progress.currentStreakDays;

    final title = hasStreak
        ? '${personal ? 'Sua sequência' : 'Sequência'} de $days ${days == 1 ? 'dia' : 'dias'}'
        : (personal ? 'Seu nível ${progress.level}' : 'Nível ${progress.level} da história');

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadii.card),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: palette.surface,
              borderRadius: BorderRadius.circular(AppRadii.card),
              border: Border.all(color: palette.outline),
            ),
            child: Row(
              children: [
                Text(hasStreak ? '🔥' : '✨', style: const TextStyle(fontSize: 20)),
                kSpacerWidth12,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      Text(
                        'Nível ${progress.level} • ${progress.points} pontos',
                        style: textTheme.bodySmall?.copyWith(color: palette.onSurfaceMuted),
                      ),
                    ],
                  ),
                ),
                Text(
                  personal ? 'Ver perfil' : 'Ver conquistas',
                  style: textTheme.labelMedium?.copyWith(
                    color: palette.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Icon(Icons.chevron_right_rounded, size: 18, color: palette.primary),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Stories row ──────────────────────────────────────────────────────────────

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
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        itemCount: timelines.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return _StoryBubble(
              label: 'Todas',
              active: activeId == null,
              accent: palette.primary,
              coverUrl: '',
              isAll: true,
              onTap: () => onTap(null),
            );
          }
          final timeline = timelines[index - 1];
          final accent = timeline.accentColor != null ? Color(timeline.accentColor!) : palette.primary;
          return _StoryBubble(
            label: timeline.name.isNotEmpty ? timeline.name : 'Linha',
            active: activeId == timeline.id,
            accent: accent,
            coverUrl: timeline.coverPhotoUrl,
            isAll: false,
            onTap: () => onTap(timeline.id),
          );
        },
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

// ── Active timeline banner ────────────────────────────────────────────────────

class _ActiveTimelineBanner extends StatelessWidget {
  const _ActiveTimelineBanner({required this.timeline, required this.onOpen});

  final TimeLine timeline;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final textTheme = Theme.of(context).textTheme;
    final accent = timeline.accentColor != null ? Color(timeline.accentColor!) : palette.primary;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: InkWell(
        onTap: onOpen,
        borderRadius: BorderRadius.circular(AppRadii.card),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: palette.surface,
            borderRadius: BorderRadius.circular(AppRadii.card),
            border: Border.all(color: palette.outline),
          ),
          child: Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(color: accent, shape: BoxShape.circle),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Filtrando: ${timeline.name}',
                  style: textTheme.bodySmall?.copyWith(color: palette.onSurfaceMuted),
                ),
              ),
              Text(
                'Abrir ajustes',
                style: textTheme.bodySmall?.copyWith(color: accent, fontWeight: FontWeight.w600),
              ),
              const SizedBox(width: 4),
              Icon(Icons.settings_outlined, size: 14, color: accent),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Feed UI helpers ──────────────────────────────────────────────────────────

class _FeedHeader extends StatelessWidget {
  const _FeedHeader({required this.timelineCount, required this.momentCount});

  final int timelineCount;
  final int momentCount;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final palette = context.palette;
    final timelineLabel = timelineCount == 1 ? '1 história' : '$timelineCount histórias';
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
          Text('Em qual história?', style: textTheme.titleLarge),
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
                final name = timeline.name.isNotEmpty ? timeline.name : 'Nossa história';
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

class _CreateTimelineCardFeed extends StatelessWidget {
  const _CreateTimelineCardFeed({required this.onCreateTimeline});

  final void Function(String momentEditPolicy) onCreateTimeline;

  Future<void> _onCreate(BuildContext context) async {
    final policy = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _MomentEditPolicySheet(),
    );
    if (policy == null) return;
    onCreateTimeline(policy);
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
              key: const ValueKey('key_timeline_create_confirm_button'),
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

class _HelpNote extends StatelessWidget {
  const _HelpNote();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final palette = context.palette;
    return Container(
      padding: const EdgeInsets.all(14),
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(color: palette.surfaceAlt, borderRadius: BorderRadius.circular(AppRadii.input)),
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

// ── Detail mode support classes ──────────────────────────────────────────────

class _SwipeDeleteBackground extends StatelessWidget {
  const _SwipeDeleteBackground({required this.alignment});

  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(color: palette.danger, borderRadius: BorderRadius.circular(AppRadii.card)),
      alignment: Alignment.center,
      child: const Icon(Icons.delete_outline_rounded, color: Colors.white, size: 28),
    );
  }
}

class _DateFilterSheet extends StatefulWidget {
  const _DateFilterSheet({
    required this.startDate,
    required this.endDate,
    required this.momentDates,
    required this.onApply,
  });

  final DateTime startDate;
  final DateTime endDate;
  final List<DateTime> momentDates;
  final void Function(DateTime start, DateTime end) onApply;

  @override
  State<_DateFilterSheet> createState() => _DateFilterSheetState();
}

class _DateFilterSheetState extends State<_DateFilterSheet> {
  final DateRangePickerController _controller = DateRangePickerController();
  late PickerDateRange _range = PickerDateRange(widget.startDate, widget.endDate);

  static const List<(String, int, int)> _presets = [
    ('Último mês', 0, 1),
    ('Último ano', 1, 0),
    ('Últimos 3 anos', 3, 0),
    ('Últimos 5 anos', 5, 0),
    ('Tudo', 100, 0),
  ];

  @override
  void initState() {
    super.initState();
    _controller.selectedRange = _range;
    _controller.displayDate = widget.startDate;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _applyPreset(int yearsBack, int monthsBack) {
    final now = DateTime.now();
    final start = DateTime(now.year - yearsBack, now.month - monthsBack, now.day);
    final end = DateTime(now.year, now.month, now.day).add(const Duration(days: 1));
    setState(() => _range = PickerDateRange(start, end));
    _controller.selectedRange = _range;
    _controller.displayDate = DateTime(now.year, now.month);
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final textTheme = Theme.of(context).textTheme;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Filtrar período', style: textTheme.headlineSmall),
            kSpacerHeight8,
            Text(
              'Use um atalho ou escolha as datas no calendário.',
              style: textTheme.bodyMedium?.copyWith(color: palette.onSurfaceMuted),
            ),
            kSpacerHeight16,
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _presets.map((p) => _PresetChip(label: p.$1, onTap: () => _applyPreset(p.$2, p.$3))).toList(),
            ),
            kSpacerHeight16,
            SizedBox(
              height: 320,
              child: SfDateRangePicker(
                controller: _controller,
                view: DateRangePickerView.month,
                selectionMode: DateRangePickerSelectionMode.range,
                allowViewNavigation: false,
                showNavigationArrow: true,
                backgroundColor: Colors.transparent,
                todayHighlightColor: palette.primary,
                selectionColor: palette.primary,
                startRangeSelectionColor: palette.primary,
                endRangeSelectionColor: palette.primary,
                rangeSelectionColor: palette.primarySoft,
                selectionTextStyle: TextStyle(color: palette.onPrimary, fontWeight: FontWeight.w600),
                rangeTextStyle: TextStyle(color: palette.onSurface),
                headerStyle: DateRangePickerHeaderStyle(
                  textAlign: TextAlign.center,
                  backgroundColor: Colors.transparent,
                  textStyle: textTheme.titleMedium,
                ),
                monthCellStyle: DateRangePickerMonthCellStyle(
                  textStyle: textTheme.bodyMedium,
                  todayTextStyle: textTheme.bodyMedium?.copyWith(color: palette.primary, fontWeight: FontWeight.w700),
                  specialDatesDecoration: BoxDecoration(
                    color: palette.primarySoft,
                    shape: BoxShape.circle,
                    border: Border.all(color: palette.primary, width: 1.2),
                  ),
                  specialDatesTextStyle: textTheme.bodyMedium?.copyWith(
                    color: palette.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                monthViewSettings: DateRangePickerMonthViewSettings(
                  firstDayOfWeek: 1,
                  specialDates: widget.momentDates,
                ),
                onSelectionChanged: (args) {
                  if (args.value is PickerDateRange) _range = args.value;
                },
              ),
            ),
            if (widget.momentDates.isNotEmpty) ...[
              kSpacerHeight12,
              Row(
                children: [
                  Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: palette.primarySoft,
                      shape: BoxShape.circle,
                      border: Border.all(color: palette.primary, width: 1.2),
                    ),
                  ),
                  kSpacerWidth8,
                  Text('Dias com momentos', style: textTheme.bodySmall),
                ],
              ),
            ],
            kSpacerHeight16,
            PrimaryButton(
              label: 'Aplicar',
              onPressed: () {
                final start = _range.startDate;
                final end = _range.endDate ?? _range.startDate;
                if (start != null && end != null) widget.onApply(start, end);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _DateHeader extends StatelessWidget {
  const _DateHeader({required this.label, required this.count});

  final String label;
  final int count;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 8),
      child: Row(
        children: [
          Text(label, style: Theme.of(context).textTheme.titleLarge),
          kSpacerWidth8,
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(color: palette.primarySoft, borderRadius: BorderRadius.circular(AppRadii.pill)),
            child: Text(
              '$count',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: palette.primary, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}


class _PresetChip extends StatelessWidget {
  const _PresetChip({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Material(
      color: palette.surfaceAlt,
      borderRadius: BorderRadius.circular(AppRadii.pill),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.pill),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
          child: Text(label, style: Theme.of(context).textTheme.titleSmall?.copyWith(color: palette.onSurface)),
        ),
      ),
    );
  }
}
