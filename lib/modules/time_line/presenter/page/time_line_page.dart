import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:nossos_momentos/di/injection.dart';
import 'package:nossos_momentos/modules/core/presenter/widgets/background_gradient.dart';
import 'package:nossos_momentos/modules/core/presenter/widgets/loading_effect.dart';
import 'package:nossos_momentos/modules/core/presenter/widgets/primary_app_bar.dart';
import 'package:nossos_momentos/modules/core/presenter/widgets/primary_button.dart';
import 'package:nossos_momentos/modules/core/utils/theme/app_theme.dart';
import 'package:nossos_momentos/modules/moment/domain/entities/moment.dart';
import 'package:nossos_momentos/modules/moment/domain/entities/moment_type.dart';
import 'package:nossos_momentos/modules/time_line/domain/entity/time_line.dart';
import 'package:nossos_momentos/modules/time_line/presenter/utils/relationship_duration.dart';
import 'package:nossos_momentos/modules/time_line/presenter/bloc/time_line_bloc.dart';
import 'package:nossos_momentos/modules/time_line/presenter/page/moments_map_page.dart';
import 'package:nossos_momentos/modules/time_line/presenter/page/on_this_day_page.dart';
import 'package:nossos_momentos/modules/time_line/presenter/widgets/memory_card.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

import '../../../core/presenter/routes.dart';
import '../../../core/presenter/widgets/custom_delete_dialog.dart';
import '../../../moment/presenter/bloc/add_or_edit_moment_bloc.dart';

class TimeLinePage extends StatefulWidget {
  const TimeLinePage({super.key});

  @override
  State<TimeLinePage> createState() => _TimeLinePageState();
}

class _TimeLinePageState extends State<TimeLinePage> {
  @override
  Widget build(BuildContext context) {
    final timeLine = ModalRoute.of(context)?.settings.arguments as String?;

    return BlocProvider<TimeLineBloc>(
      create: (_) => getIt<TimeLineBloc>()..add(TimeLineEventInit(timeLineId: timeLine)),
      child: BlocBuilder<TimeLineBloc, TimeLineState>(
        builder: (context, state) {
          final accentValue = (state is TimeLineStateLoaded || state is TimeLineStateEmpty)
              ? context.read<TimeLineBloc>().timeLine.accentColor
              : null;
          return AppAccent(
            color: accentValue == null ? null : Color(accentValue),
            child: Builder(builder: (context) {
              return Stack(
            children: [
              Scaffold(
                appBar: PrimaryAppBar(
                  title: _timelineTitle(context, state),
                  background: BackgroundGradient(),
                  icons: [
                    IconButton(
                      icon: Icon(Icons.add_circle_outline),
                      onPressed: () => _goToAddMoment(context),
                    ),
                    IconButton(
                      icon: Icon(Icons.filter_alt_outlined),
                      onPressed: () => _showDatePicker(context, state),
                    ),
                    IconButton(
                      icon: Icon(Icons.map_outlined),
                      onPressed: () => _openMomentsMap(context),
                    ),
                    IconButton(
                      icon: Icon(Icons.settings_outlined),
                      onPressed: () => _goToSettings(context, context.read<TimeLineBloc>().timeLine),
                    ),
                  ],
                  bottom: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text('De: ${DateFormat('dd/MM/yyyy').format(state.startDate)}'),
                      Text('Até: ${DateFormat('dd/MM/yyyy').format(state.endDate)}'),
                    ],
                  ),
                ),
                body: state is TimeLineStateLoaded || state is TimeLineStateEmpty
                    ? Column(
                        children: [
                          _buildOnThisDayBanner(context),
                          _buildTogetherCounter(context),
                          _buildControls(context),
                          Expanded(child: _buildTimeLine(state)),
                        ],
                      )
                    : _buildLoadingState(),
              ),
            ],
              );
            }),
          );
        },
      ),
    );
  }

  String _searchQuery = '';
  MomentType? _typeFilter;
  bool _showFavoritesOnly = false;

  String _timelineTitle(BuildContext context, TimeLineState state) {
    if (state is TimeLineStateLoaded || state is TimeLineStateEmpty) {
      final name = context.read<TimeLineBloc>().timeLine.name;
      if (name.isNotEmpty) return name;
    }
    return Strings.appName;
  }

  Widget _buildOnThisDayBanner(BuildContext context) {
    final now = DateTime.now();
    final onThisDay = context
        .read<TimeLineBloc>()
        .allMoments
        .where((m) =>
            m.dateTime.month == now.month &&
            m.dateTime.day == now.day &&
            m.dateTime.year < now.year)
        .toList();

    if (onThisDay.isEmpty) return const SizedBox.shrink();

    final palette = context.palette;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      child: GestureDetector(
        onTap: () => _openOnThisDay(context, onThisDay),
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
                      style: textTheme.titleSmall?.copyWith(
                        color: palette.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      onThisDay.length == 1
                          ? '1 memória de outro ano'
                          : '${onThisDay.length} memórias de outros anos',
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

  Future<void> _openOnThisDay(BuildContext context, List<Moment> moments) async {
    final selected = await Navigator.of(context).push<Moment>(
      MaterialPageRoute(builder: (_) => OnThisDayPage(moments: moments)),
    );
    if (selected != null && context.mounted) {
      _openMoment(context, selected);
    }
  }

  Widget _buildTogetherCounter(BuildContext context) {
    final palette = context.palette;
    final textTheme = Theme.of(context).textTheme;
    final startDate = context.read<TimeLineBloc>().timeLine.relationshipStartDate;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 2),
      child: GestureDetector(
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
                            'Juntos há',
                            style: textTheme.bodySmall?.copyWith(
                              color: Colors.white.withValues(alpha: 0.85),
                            ),
                          ),
                          Text(
                            RelationshipDuration.friendly(startDate),
                            style: textTheme.titleMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
              ),
              Icon(
                startDate == null ? Icons.add_rounded : Icons.edit_calendar_outlined,
                color: Colors.white,
                size: 20,
              ),
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

  Widget _buildControls(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: TextField(
            onChanged: (value) => setState(() => _searchQuery = value),
            textInputAction: TextInputAction.search,
            decoration: const InputDecoration(
              hintText: 'Buscar momentos...',
              prefixIcon: Icon(Icons.search_rounded),
            ),
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
    final selected = _showFavoritesOnly;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () => setState(() {
          _showFavoritesOnly = !_showFavoritesOnly;
          if (_showFavoritesOnly) _typeFilter = null;
        }),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: selected ? palette.primary.withValues(alpha: 0.16) : palette.surfaceAlt,
            borderRadius: BorderRadius.circular(AppRadii.pill),
            border: Border.all(
              color: selected ? palette.primary.withValues(alpha: 0.5) : Colors.transparent,
            ),
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
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: selected ? palette.onSurface : palette.onSurfaceMuted,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _typeChip(BuildContext context, MomentType? type, String label) {
    final palette = context.palette;
    final selected = _typeFilter == type && !_showFavoritesOnly;
    final accent = type?.colors(context).accent ?? palette.primary;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () => setState(() {
          _typeFilter = selected ? null : type;
          _showFavoritesOnly = false;
        }),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: selected ? accent.withValues(alpha: 0.16) : palette.surfaceAlt,
            borderRadius: BorderRadius.circular(AppRadii.pill),
            border: Border.all(
              color: selected ? accent.withValues(alpha: 0.5) : Colors.transparent,
            ),
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
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: selected ? palette.onSurface : palette.onSurfaceMuted,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _goToAddMoment(BuildContext context) {
    final timeLineBloc = context.read<TimeLineBloc>();
    Navigator.pushNamed(context, AppRoute.addMoment.tag).then(
      (_) => timeLineBloc.add(TimeLineEventChangeDate()),
    );

    final timelineId = timeLineBloc.timelineId;

    BlocProvider.of<AddOrEditMomentBloc>(context).add(SetupAddMomentEvent(timelineId: timelineId));
  }

  void _showDatePicker(BuildContext context, TimeLineState state) {
    final bloc = context.read<TimeLineBloc>();
    final momentDates = bloc.momentDates;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) {
        return _DateFilterSheet(
          startDate: state.startDate,
          endDate: state.endDate,
          momentDates: momentDates,
          onApply: (start, end) {
            bloc.add(TimeLineEventChangeDate(startDate: start, endDate: end));
          },
        );
      },
    );
  }

  Widget _buildTimeLine(TimeLineState state) {
    final momentsList = <Moment>[];

    if (state is TimeLineStateLoaded) {
      momentsList.addAll(state.momentsList);
    }

    final query = _searchQuery.trim().toLowerCase();
    final hasFilters = query.isNotEmpty || _typeFilter != null || _showFavoritesOnly;
    final filtered = momentsList.where((m) {
      final matchesType = _typeFilter == null || m.type == _typeFilter;
      final matchesFavorite = !_showFavoritesOnly || m.isFavorite;
      final matchesQuery = query.isEmpty ||
          m.title.toLowerCase().contains(query) ||
          m.body.toLowerCase().contains(query);
      return matchesType && matchesFavorite && matchesQuery;
    }).toList();

    if (filtered.isEmpty) {
      return Center(
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
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: context.palette.onSurfaceMuted,
                  ),
            ),
          ],
        ),
      );
    }

    // Newest first.
    final sorted = [...filtered]..sort((a, b) => b.dateTime.compareTo(a.dateTime));
    final now = DateTime.now();

    // Group consecutive moments under smart, relative date labels.
    final orderedLabels = <String>[];
    final byLabel = <String, List<Moment>>{};
    for (final moment in sorted) {
      final label = _groupLabel(moment.dateTime, now);
      if (!byLabel.containsKey(label)) {
        byLabel[label] = [];
        orderedLabels.add(label);
      }
      byLabel[label]!.add(moment);
    }

    // Flatten into a header + cards list for a lazy ListView.
    final items = <Object>[];
    for (final label in orderedLabels) {
      items.add((label: label, count: byLabel[label]!.length));
      items.addAll(byLabel[label]!);
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 16),
      itemCount: items.length,
      itemBuilder: (parentContext, index) {
        final item = items[index];
        if (item is Moment) {
          return GestureDetector(
            onTap: () => _openMoment(parentContext, item),
            onLongPress: () => _showDeleteMomentDialog(parentContext, item.id),
            child: MemoryCard(
              moment: item,
              onFavoriteToggle: () => parentContext
                  .read<TimeLineBloc>()
                  .add(TimeLineEventToggleFavorite(moment: item)),
            ),
          );
        }
        final header = item as ({String label, int count});
        return _DateHeader(label: header.label, count: header.count);
      },
    );
  }

  /// Relative, human-friendly bucket for a moment's date (Hoje, Ontem,
  /// Esta semana, Este mês, "Junho", "Junho de 2023").
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

  Future<void> _openMomentsMap(BuildContext context) async {
    final bloc = context.read<TimeLineBloc>();
    final moment = await Navigator.of(context).push<Moment>(
      MaterialPageRoute(
        builder: (_) => MomentsMapPage(
          moments: bloc.allMoments,
          relationshipStartDate: bloc.timeLine.relationshipStartDate,
        ),
      ),
    );
    if (moment != null && context.mounted) {
      _openMoment(context, moment);
    }
  }

  void _openMoment(BuildContext context, Moment moment) {
    final timeLineBloc = context.read<TimeLineBloc>();
    Navigator.pushNamed(context, AppRoute.addMoment.tag).then(
      (_) => timeLineBloc.add(TimeLineEventChangeDate()),
    );

    BlocProvider.of<AddOrEditMomentBloc>(context).add(SetupEditMomentEvent(moment: moment));
  }

  Widget _buildLoadingState() {
    return Column(
      children: [
        ListView.builder(
          itemCount: 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            return LoadingEffect(
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: 160,
                margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                decoration: BoxDecoration(
                  color: context.palette.surface,
                  borderRadius: BorderRadius.circular(AppRadii.card),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  void _showDeleteMomentDialog(BuildContext context, String momentId) {
    CustomDeleteDialog.show(
      context,
      text: 'Você tem certeza que deseja remover esse momento das areias do tempo?',
      onTapPositive: () {
        context.read<TimeLineBloc>().add(TimeLineEventDeleteMoment(momentId: momentId));
        Navigator.pop(context);
      },
    );
  }

  void _goToSettings(BuildContext context, TimeLine timeLine) {
    Navigator.pushNamed(context, AppRoute.settings.tag, arguments: timeLine.id);
  }
}

/// Clean, themed date-range filter shown in a bottom sheet.
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

  /// (label, anos atrás, meses atrás)
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
              children: _presets
                  .map((p) => _PresetChip(label: p.$1, onTap: () => _applyPreset(p.$2, p.$3)))
                  .toList(),
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
                selectionTextStyle: TextStyle(
                  color: palette.onPrimary,
                  fontWeight: FontWeight.w600,
                ),
                rangeTextStyle: TextStyle(color: palette.onSurface),
                headerStyle: DateRangePickerHeaderStyle(
                  textAlign: TextAlign.center,
                  backgroundColor: Colors.transparent,
                  textStyle: textTheme.titleMedium,
                ),
                monthCellStyle: DateRangePickerMonthCellStyle(
                  textStyle: textTheme.bodyMedium,
                  todayTextStyle: textTheme.bodyMedium?.copyWith(
                    color: palette.primary,
                    fontWeight: FontWeight.w700,
                  ),
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
                  if (args.value is PickerDateRange) {
                    _range = args.value;
                  }
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
                  Text(
                    'Dias com momentos',
                    style: textTheme.bodySmall,
                  ),
                ],
              ),
            ],
            kSpacerHeight16,
            PrimaryButton(
              label: 'Aplicar',
              onPressed: () {
                final start = _range.startDate;
                final end = _range.endDate ?? _range.startDate;
                if (start != null && end != null) {
                  widget.onApply(start, end);
                }
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// Section header for the grouped memories feed (label + moment count).
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
            decoration: BoxDecoration(
              color: palette.primarySoft,
              borderRadius: BorderRadius.circular(AppRadii.pill),
            ),
            child: Text(
              '$count',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
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

/// Quick date-range shortcut chip used in the calendar filter.
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
          child: Text(
            label,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(color: palette.onSurface),
          ),
        ),
      ),
    );
  }
}
