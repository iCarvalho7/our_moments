import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:nossos_momentos/di/injection.dart';
import 'package:nossos_momentos/modules/core/presenter/widgets/background_gradient.dart';
import 'package:nossos_momentos/modules/core/presenter/widgets/primary_app_bar.dart';
import 'package:nossos_momentos/modules/core/presenter/widgets/primary_button.dart';
import 'package:nossos_momentos/modules/core/utils/theme/app_theme.dart';
import 'package:nossos_momentos/modules/notifications/notification_service.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

import '../../domain/entity/special_date.dart';
import '../bloc/special_dates_bloc.dart';

/// Couple-only special dates with reminders ("Datas especiais e lembretes").
/// Dates live in the `time_line/{id}/special_dates` subcollection and sync in
/// real time; each schedules a local reminder.
class SpecialDatesPage extends StatelessWidget {
  const SpecialDatesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final timelineId = ModalRoute.of(context)?.settings.arguments as String? ?? '';
    return BlocProvider<SpecialDatesBloc>(
      create: (_) => getIt<SpecialDatesBloc>()
        ..add(SpecialDatesStarted(timelineId: timelineId)),
      child: const _SpecialDatesView(),
    );
  }
}

class _SpecialDatesView extends StatelessWidget {
  const _SpecialDatesView();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const BackgroundGradient(),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: PrimaryAppBar(title: 'Datas especiais'),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _openAddSheet(context),
            child: const Icon(Icons.add_rounded),
          ),
          body: BlocBuilder<SpecialDatesBloc, SpecialDatesState>(
            builder: (context, state) {
              if (state.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state.dates.isEmpty) {
                return _EmptyState(onAdd: () => _openAddSheet(context));
              }
              return _SpecialDatesBody(dates: state.dates);
            },
          ),
        ),
      ],
    );
  }

  void _openAddSheet(BuildContext context) {
    final bloc = context.read<SpecialDatesBloc>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _AddSpecialDateSheet(
        onSubmit: (title, date, remindDaysBefore) {
          bloc.add(SpecialDateAdded(
            title: title,
            date: date,
            remindDaysBefore: remindDaysBefore,
          ));
        },
      ),
    );
  }
}

class _SpecialDatesBody extends StatelessWidget {
  const _SpecialDatesBody({required this.dates});

  final List<SpecialDate> dates;

  @override
  Widget build(BuildContext context) {
    // Sort by how soon the next occurrence is.
    final sorted = [...dates]..sort((a, b) {
        final da = NotificationService.nextYearlyOccurrence(a.date);
        final db = NotificationService.nextYearlyOccurrence(b.date);
        return da.compareTo(db);
      });

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
      children: sorted.map((date) => _SpecialDateTile(date: date)).toList(),
    );
  }
}

class _SpecialDateTile extends StatelessWidget {
  const _SpecialDateTile({required this.date});

  final SpecialDate date;

  /// Whole days from today until the next (yearly) occurrence.
  int get _daysUntil {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final next = NotificationService.nextYearlyOccurrence(date.date);
    final nextDay = DateTime(next.year, next.month, next.day);
    return nextDay.difference(today).inDays;
  }

  String get _countdownLabel {
    final days = _daysUntil;
    if (days <= 0) return 'É hoje! 🎉';
    if (days == 1) return 'Amanhã';
    return 'Faltam $days dias';
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final textTheme = Theme.of(context).textTheme;
    final bloc = context.read<SpecialDatesBloc>();
    final formatted = DateFormat('dd/MM', 'pt_BR').format(date.date);

    return Dismissible(
      key: ValueKey(date.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => bloc.add(SpecialDateRemoved(date.id)),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: palette.danger.withValues(alpha: 0.16),
          borderRadius: BorderRadius.circular(AppRadii.card),
        ),
        child: Icon(Icons.delete_outline_rounded, color: palette.danger),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: palette.surface,
          borderRadius: BorderRadius.circular(AppRadii.card),
          border: Border.all(color: palette.outline),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: palette.primarySoft,
                borderRadius: BorderRadius.circular(AppRadii.input),
              ),
              child: Icon(Icons.event_rounded, color: palette.primary),
            ),
            kSpacerWidth12,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(date.title, style: textTheme.bodyLarge),
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      '$formatted · $_countdownLabel',
                      style: textTheme.bodySmall?.copyWith(color: palette.primary),
                    ),
                  ),
                  if (date.remindDaysBefore > 0)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        'Lembrete ${date.remindDaysBefore} '
                        '${date.remindDaysBefore == 1 ? 'dia' : 'dias'} antes',
                        style: textTheme.bodySmall
                            ?.copyWith(color: palette.onSurfaceMuted),
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

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.event_outlined, size: 48, color: palette.onSurfaceMuted),
            kSpacerHeight16,
            Text('Nenhuma data ainda', style: textTheme.titleMedium),
            kSpacerHeight8,
            Text(
              'Guarde aniversários e datas importantes e receba lembretes.',
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(color: palette.onSurfaceMuted),
            ),
            kSpacerHeight24,
            PrimaryButton(label: 'Adicionar data', onPressed: onAdd),
          ],
        ),
      ),
    );
  }
}

class _AddSpecialDateSheet extends StatefulWidget {
  const _AddSpecialDateSheet({required this.onSubmit});

  final void Function(String title, DateTime date, int remindDaysBefore)
      onSubmit;

  @override
  State<_AddSpecialDateSheet> createState() => _AddSpecialDateSheetState();
}

class _AddSpecialDateSheetState extends State<_AddSpecialDateSheet> {
  final _titleController = TextEditingController();
  DateTime _date = DateTime.now();
  int _remindDaysBefore = 1;

  static const _reminderOptions = [0, 1, 3, 7];

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  void _submit() {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;
    widget.onSubmit(title, _date, _remindDaysBefore);
    Navigator.pop(context);
  }

  String _reminderLabel(int days) {
    if (days == 0) return 'No dia';
    if (days == 1) return '1 dia antes';
    return '$days dias antes';
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final textTheme = Theme.of(context).textTheme;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          4,
          20,
          20 + MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Nova data especial', style: textTheme.headlineSmall),
              kSpacerHeight16,
              TextField(
                controller: _titleController,
                textCapitalization: TextCapitalization.sentences,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'Qual é a data?',
                  prefixIcon: Icon(Icons.favorite_outline_rounded),
                ),
              ),
              kSpacerHeight16,
              Text('Dia', style: textTheme.titleSmall),
              kSpacerHeight8,
              SizedBox(
                height: 300,
                child: SfDateRangePicker(
                  view: DateRangePickerView.month,
                  selectionMode: DateRangePickerSelectionMode.single,
                  initialSelectedDate: _date,
                  allowViewNavigation: true,
                  backgroundColor: Colors.transparent,
                  todayHighlightColor: palette.primary,
                  selectionColor: palette.primary,
                  selectionTextStyle: TextStyle(
                    color: palette.onPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                  headerStyle: DateRangePickerHeaderStyle(
                    textAlign: TextAlign.center,
                    backgroundColor: Colors.transparent,
                    textStyle: textTheme.titleMedium,
                  ),
                  monthCellStyle: DateRangePickerMonthCellStyle(
                    textStyle: textTheme.bodyMedium,
                  ),
                  onSelectionChanged: (args) {
                    if (args.value is DateTime) {
                      _date = args.value as DateTime;
                    }
                  },
                ),
              ),
              kSpacerHeight16,
              Text('Lembrete', style: textTheme.titleSmall),
              kSpacerHeight8,
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _reminderOptions.map((days) {
                  final selected = _remindDaysBefore == days;
                  return ChoiceChip(
                    label: Text(_reminderLabel(days)),
                    selected: selected,
                    onSelected: (_) =>
                        setState(() => _remindDaysBefore = days),
                  );
                }).toList(),
              ),
              kSpacerHeight16,
              PrimaryButton(label: 'Adicionar', onPressed: _submit),
            ],
          ),
        ),
      ),
    );
  }
}
