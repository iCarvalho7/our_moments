import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/utils/theme/app_theme.dart';
import '../../domain/entities/moment_type.dart';
import '../bloc/add_or_edit_moment_bloc.dart';

class SelectTypeToggle extends StatelessWidget {
  const SelectTypeToggle({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AddOrEditMomentBloc, AddOrEditMomentState>(
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: MomentType.values.map((type) {
              return _TypeToggle(
                isSelected: state.moment.type == type,
                type: type,
                onPressed: () => _addType(type, context),
              );
            }).toList(),
          ),
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
    required this.onPressed,
    required this.isSelected,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final colors = type.colors(context);

    return GestureDetector(
      onTap: onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? colors.bg : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadii.pill),
          border: Border.all(
            color: isSelected ? colors.accent.withValues(alpha: 0.4) : palette.outline,
          ),
        ),
        child: Row(
          children: [
            Icon(
              type.icon,
              size: 20,
              color: isSelected ? colors.accent : palette.onSurfaceMuted,
            ),
            kSpacerWidth8,
            Text(
              type.label,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: isSelected ? colors.onBg : palette.onSurfaceMuted,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
