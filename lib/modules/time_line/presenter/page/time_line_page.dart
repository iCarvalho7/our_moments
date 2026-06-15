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
import 'package:nossos_momentos/modules/time_line/domain/entity/time_line.dart';
import 'package:nossos_momentos/modules/time_line/presenter/bloc/time_line_bloc.dart';
import 'package:nossos_momentos/modules/time_line/presenter/widgets/card_moment.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:timeline_tile/timeline_tile.dart';

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
          return Stack(
            children: [
              Scaffold(
                appBar: PrimaryAppBar(
                  title: Strings.appName,
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
                body: state is TimeLineStateLoading ? _buildLoadingState() : _buildTimeLine(state),
              ),
            ],
          );
        },
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

    if (momentsList.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.auto_awesome_outlined, size: 48, color: context.palette.onSurfaceMuted),
            kSpacerHeight16,
            Text(
              'Nenhum momento nessa data ainda',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            kSpacerHeight8,
            Text(
              'Toque em + para registrar o primeiro.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: context.palette.onSurfaceMuted,
                  ),
            ),
          ],
        ),
      );
    }

    final lineColor = context.palette.primary.withValues(alpha: 0.4);

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: ListView.builder(
        itemCount: momentsList.length,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (parentContext, index) {
          return GestureDetector(
            onLongPress: () => _showDeleteMomentDialog(
              parentContext,
              momentsList[index].id,
            ),
            child: TimelineTile(
              alignment: TimelineAlign.manual,
              lineXY: 0.08,
              beforeLineStyle: LineStyle(color: lineColor),
              afterLineStyle: LineStyle(color: lineColor),
              indicatorStyle: const IndicatorStyle(
                height: 16,
                width: 16,
                color: Colors.transparent,
                indicator: _CircularIndicator(),
              ),
              endChild: CardMoment(moment: momentsList[index]),
            ),
          );
        },
      ),
    );
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

class _CircularIndicator extends StatelessWidget {
  const _CircularIndicator();

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
      decoration: BoxDecoration(
        color: palette.primary,
        shape: BoxShape.circle,
        border: Border.all(color: palette.background, width: 3),
      ),
    );
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
