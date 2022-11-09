import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nossos_momentos/di/injection.dart';
import '../../domain/entities/moment_type.dart';
import '../bloc/add_or_edit_moment_bloc.dart';
import '../bloc/select_type_bloc.dart';
import 'type_toggle.dart';

class SelectTypeToggle extends StatelessWidget {
  const SelectTypeToggle({Key? key, this.index = 0}) : super(key: key);

  final int index;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SelectTypeBloc>(
      create: (_) => getIt<SelectTypeBloc>()..add(SelectTypeEventSelectType(index: index)),
      child: BlocBuilder<SelectTypeBloc, SelectTypeState>(
        builder: (context, state) {
          if (state is SelectTypeStateLoaded) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                TypeToggle(
                  isSelected: state.selectedItems[MomentType.bad.index],
                  type: MomentType.bad,
                  onPressed: () => _addType(MomentType.bad, context),
                ),
                TypeToggle(
                  isSelected: state.selectedItems[MomentType.romantic.index],
                  type: MomentType.romantic,
                  onPressed: () => _addType(MomentType.romantic, context),
                ),
                TypeToggle(
                  isSelected: state.selectedItems[MomentType.good.index],
                  type: MomentType.good,
                  onPressed: () => _addType(MomentType.good, context),
                ),
              ],
            );
          } else {
            return const SizedBox.shrink();
          }
        },
      ),
    );
  }

  void _addType(MomentType type, BuildContext context) {
    BlocProvider.of<AddOrEditMomentBloc>(context).add(
      AddOrEditMomentEventSelectType(type: type),
    );

    BlocProvider.of<SelectTypeBloc>(context).add(SelectTypeEventSelectType(
      index: type.index,
    ));
  }
}
