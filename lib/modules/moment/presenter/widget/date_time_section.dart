import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nossos_momentos/di/injection.dart';
import '../bloc/add_date_bloc.dart';
import '../bloc/add_or_edit_moment_bloc.dart';
import '../../../core/utils/date_util.dart';
import '../../../core/utils/theme/app_theme.dart';

class DateTimeSection extends StatelessWidget {
  const DateTimeSection({Key? key, required this.dateText}) : super(key: key);

  final String? dateText;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AddDateBloc>(
      create: (_) => getIt<AddDateBloc>(),
      child: BlocBuilder<AddDateBloc, AddDateState>(
        builder: (context, state) {
          final label = dateText ?? state.text;
          return GestureDetector(
            onTap: () => _showDatePicker(context),
            child: Row(
              children: [
                Text(
                  label,
                  style: AppThemes.kLightBodyStyle.copyWith(
                    color: label == AddDateBloc.defaultText
                        ? Colors.grey
                        : Colors.black,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showDatePicker(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      lastDate: DateTime(2024, 1, 1),
      firstDate: DateTime(2018, 1, 1),
    );

    if (date != null) {
      BlocProvider.of<AddDateBloc>(context).add(
        AddDateEventAddDateToLabel(dateLabel: DateUtil.getFormattedDate(date)),
      );

      BlocProvider.of<AddOrEditMomentBloc>(context)
          .add(AddOrEditMomentEventAddDateTime(date: date));
    }
  }
}
