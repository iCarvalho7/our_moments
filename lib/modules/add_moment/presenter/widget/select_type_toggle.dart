import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nossos_momentos/dependencie_injection/injection.dart';
import 'package:nossos_momentos/modules/add_moment/domain/entities/moment_type.dart';
import 'package:nossos_momentos/modules/add_moment/presenter/bloc/add_or_edit_moment_bloc.dart';
import 'package:nossos_momentos/modules/add_moment/presenter/bloc/add_or_edit_moment_event.dart';
import 'package:nossos_momentos/modules/add_moment/presenter/bloc/select_type_bloc.dart';
import 'package:nossos_momentos/modules/add_moment/presenter/bloc/select_type_event.dart';
import 'package:nossos_momentos/modules/add_moment/presenter/bloc/select_type_state.dart';
import 'package:nossos_momentos/modules/add_moment/presenter/widget/type_toggle.dart';

class SelectTypeToggle extends StatefulWidget {
  const SelectTypeToggle({
    Key? key,
  }) : super(key: key);

  @override
  State<SelectTypeToggle> createState() => _SelectTypeToggleState();
}

class _SelectTypeToggleState extends State<SelectTypeToggle> {
  final selectTypeBloc = getIt<SelectTypeBloc>()
    ..add(const SelectTypeEventSelectType(index: 0));

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => selectTypeBloc,
      child: BlocBuilder<SelectTypeBloc, SelectTypeState>(
          builder: (context, state) {
        if (state is SelectTypeStateLoaded) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              TypeToggle(
                isSelected: state.selectedItems[MomentType.bad.index],
                type: MomentType.bad,
                onPressed: () => _addType(MomentType.bad),
              ),
              TypeToggle(
                isSelected: state.selectedItems[MomentType.romantic.index],
                type: MomentType.romantic,
                onPressed: () => _addType(MomentType.romantic),
              ),
              TypeToggle(
                isSelected: state.selectedItems[MomentType.good.index],
                type: MomentType.good,
                onPressed: () => _addType(MomentType.good),
              ),
            ],
          );
        } else {
          return const SizedBox.shrink();
        }
      }),
    );
  }

  void _addType(MomentType type) {
    BlocProvider.of<AddOrEditMomentBloc>(context).add(
      AddOrEditMomentEventSelectType(type: type),
    );

    selectTypeBloc.add(
      SelectTypeEventSelectType(index: type.index),
    );
  }
}
