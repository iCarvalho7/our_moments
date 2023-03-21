import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/moment_type.dart';
import '../bloc/add_or_edit_moment_bloc.dart';
import 'type_toggle.dart';

class SelectTypeToggle extends StatelessWidget {
  const SelectTypeToggle({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AddOrEditMomentBloc, AddOrEditMomentState>(
      builder: (context, state) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            TypeToggle(
              isSelected: state.moment.type == MomentType.bad,
              type: MomentType.bad,
              onPressed: () => _addType(MomentType.bad, context),
            ),
            TypeToggle(
              isSelected: state.moment.type == MomentType.romantic,
              type: MomentType.romantic,
              onPressed: () => _addType(MomentType.romantic, context),
            ),
            TypeToggle(
              isSelected: state.moment.type == MomentType.good,
              type: MomentType.good,
              onPressed: () => _addType(MomentType.good, context),
            ),
          ],
        );
      },
    );
  }

  void _addType(MomentType type, BuildContext context) {
    context
        .read<AddOrEditMomentBloc>()
        .add(AddOrEditMomentEventSelectType(type: type));
  }
}
