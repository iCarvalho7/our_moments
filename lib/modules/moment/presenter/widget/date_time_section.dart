import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/add_or_edit_moment_bloc.dart';

class DateTimeSection extends StatelessWidget {
  const DateTimeSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AddOrEditMomentBloc, AddOrEditMomentState>(
      builder: (context, state) {
        final label = state.moment.dateTimeComplete;
        return GestureDetector(
          onTap: () => _showDatePicker(context),
          child: Padding(
            padding: const EdgeInsets.only(top: 32.0, left: 8.0),
            child: Row(
              children: [
                Text(
                  'Aconteceu em: $label',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: label == addDate ? Colors.grey : Colors.black,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showDatePicker(BuildContext context) {
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      lastDate: DateTime(2024, 1, 1),
      firstDate: DateTime(2018, 1, 1),
    ).then((date) => _sendAddDateTime(context, date));
  }

  void _sendAddDateTime(BuildContext context, DateTime? date) {
    if (date != null) {
      BlocProvider.of<AddOrEditMomentBloc>(context)
          .add(AddOrEditMomentEventAddDateTime(date: date));
    }
  }

  static const addDate = 'Adicionar Data +';
}
