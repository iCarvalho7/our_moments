import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:nossos_momentos/dependencie_injection/injection.dart';
import 'package:nossos_momentos/modules/add_moment/presenter/bloc/add_date_bloc.dart';
import 'package:nossos_momentos/modules/add_moment/presenter/bloc/add_date_event.dart';
import 'package:nossos_momentos/modules/add_moment/presenter/bloc/add_date_state.dart';
import 'package:nossos_momentos/modules/add_moment/presenter/bloc/add_or_edit_moment_bloc.dart';
import 'package:nossos_momentos/modules/add_moment/presenter/bloc/add_or_edit_moment_event.dart';
import 'package:nossos_momentos/modules/core/utils/theme/app_theme.dart';

class DateTimeSection extends StatelessWidget {
  DateTimeSection({Key? key}) : super(key: key);

  final addDateBloc = getIt<AddDateBloc>();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => addDateBloc,
      child: BlocBuilder<AddDateBloc, AddDateState>(builder: (context, state) {
        return GestureDetector(
          onTap: () => _showDatePicker(context),
          child: Row(
            children: [
              Text(
                state.text,
                style: AppThemes.kLightBodyStyle.copyWith(
                  color: state.text == AddDateBloc.defaultText
                      ? Colors.grey
                      : Colors.black,
                ),
              ),
            ],
          ),
        );
      }),
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
      addDateBloc.add(
        AddDateEventAddDateToLabel(dateLabel: _getFormattedDate(date)),
      );


      BlocProvider.of<AddOrEditMomentBloc>(context)
          .add(AddOrEditMomentEventAddDateTime(date: date));
    }
  }

  String _getFormattedDate(DateTime date) =>
      "${date.day} de ${DateFormat(DateFormat.WEEKDAY).format(date)} de ${date.year}";
}
