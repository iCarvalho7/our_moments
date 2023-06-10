import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/utils/theme/app_theme.dart';
import '../../domain/entities/moment_type.dart';
import '../bloc/add_or_edit_moment_bloc.dart';

class SelectTypeToggle extends StatelessWidget {
  const SelectTypeToggle({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AddOrEditMomentBloc, AddOrEditMomentState>(
      builder: (context, state) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _TypeToggle(
              isSelected: state.moment.type == MomentType.bad,
              type: MomentType.bad,
              onPressed: () => _addType(MomentType.bad, context),
            ),
            _TypeToggle(
              isSelected: state.moment.type == MomentType.romantic,
              type: MomentType.romantic,
              onPressed: () => _addType(MomentType.romantic, context),
            ),
            _TypeToggle(
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
    context.read<AddOrEditMomentBloc>().add(AddOrEditMomentEventSelectType(type: type));
  }
}

class _TypeToggle extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isSelected;
  final MomentType type;

  const _TypeToggle({
    Key? key,
    required this.onPressed,
    required this.isSelected,
    required this.type,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Row(
        children: [
          _getIcon(),
          const SizedBox(width: 5),
          Text(
            type.value,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: isSelected ? Colors.black : Colors.grey,
            ),
          )
        ],
      ),
    );
  }

  Icon _getIcon() {
    switch (type) {
      case MomentType.bad:
        return Icon(
          Icons.mood_bad_sharp,
          color: isSelected ? AppColors.badColor : Colors.grey,
        );
      case MomentType.romantic:
        return Icon(
          CupertinoIcons.heart_fill,
          color: isSelected ? AppColors.romanticColor : Colors.grey,
        );
      case MomentType.good:
        return Icon(
          Icons.tag_faces,
          color: isSelected ? AppColors.goodColor : Colors.grey,
        );
    }
  }
}
