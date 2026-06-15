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
        final label = state.moment.dateTimeComplete;
        final isPlaceholder = label == addDate;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: GestureDetector(
            onTap: () => _showDatePicker(context),
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
                  Text(
                    isPlaceholder ? 'Selecionar data' : label,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: isPlaceholder ? palette.onSurfaceMuted : palette.onSurface,
                        ),
                  ),
                  const Spacer(),
                  Icon(Icons.chevron_right_rounded, color: palette.onSurfaceMuted),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showDatePicker(BuildContext context) {
    final bloc = BlocProvider.of<AddOrEditMomentBloc>(context);
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      lastDate: DateTime(2030, 1, 1),
      firstDate: DateTime(2018, 1, 1),
    ).then((date) => _sendAddDateTime(bloc, date));
  }

  void _sendAddDateTime(AddOrEditMomentBloc bloc, DateTime? date) {
    if (date != null) {
      bloc.add(AddOrEditMomentEventAddDateTime(date: date));
    }
  }

  static const addDate = 'Adicionar Data +';
}
