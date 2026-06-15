import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/utils/theme/app_theme.dart';
import '../bloc/add_or_edit_moment_bloc.dart';

class DateTimeSection extends StatelessWidget {
  const DateTimeSection({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return BlocBuilder<AddOrEditMomentBloc, AddOrEditMomentState>(
      builder: (context, state) {
        final moment = state.moment;
        final dateLabel = moment.dateTimeComplete;
        final isPlaceholder = dateLabel == addDate;

        final hasTime = !isPlaceholder &&
            (moment.dateTime.hour != 0 || moment.dateTime.minute != 0);
        final label = isPlaceholder
            ? 'Selecionar data e hora'
            : (hasTime ? '$dateLabel · ${_timeLabel(moment.dateTime)}' : dateLabel);

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: GestureDetector(
            onTap: () => _pickDateTime(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                color: palette.surfaceAlt,
                borderRadius: BorderRadius.circular(AppRadii.input),
              ),
              child: Row(
                children: [
                  Icon(Icons.calendar_today_rounded, size: 20, color: palette.onSurfaceMuted),
                  kSpacerWidth12,
                  Expanded(
                    child: Text(
                      label,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: isPlaceholder ? palette.onSurfaceMuted : palette.onSurface,
                          ),
                    ),
                  ),
                  Icon(Icons.chevron_right_rounded, color: palette.onSurfaceMuted),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _pickDateTime(BuildContext context) async {
    final bloc = BlocProvider.of<AddOrEditMomentBloc>(context);
    final current = bloc.state.moment.dateTime;
    final hasDate = current != AddOrEditMomentBloc.defaultDateTime;

    final date = await showDatePicker(
      context: context,
      initialDate: hasDate ? current : DateTime.now(),
      firstDate: DateTime(2018, 1, 1),
      lastDate: DateTime(2030, 1, 1),
    );
    if (date == null || !context.mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: hasDate ? TimeOfDay.fromDateTime(current) : TimeOfDay.now(),
    );

    final combined = DateTime(date.year, date.month, date.day, time?.hour ?? 0, time?.minute ?? 0);
    bloc.add(AddOrEditMomentEventAddDateTime(date: combined));
  }

  String _timeLabel(DateTime dt) =>
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

  static const addDate = 'Adicionar Data +';
}
