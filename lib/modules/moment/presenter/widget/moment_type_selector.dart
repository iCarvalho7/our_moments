import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/utils/theme/app_theme.dart';
import '../../domain/entities/moment_type.dart';
import '../bloc/add_or_edit_moment_bloc.dart';

/// Horizontally-scrollable chip row for the moment "mood". Replaces the old
/// fixed-width segmented control, which broke when more than ~4 types exist.
class MomentTypeSelector extends StatelessWidget {
  const MomentTypeSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AddOrEditMomentBloc, AddOrEditMomentState>(
      buildWhen: (p, c) => p.moment.type != c.moment.type,
      builder: (context, state) {
        return SizedBox(
          height: 42,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: MomentType.values.map((type) {
              return _Chip(
                type: type,
                selected: state.moment.type == type,
                onTap: () => context
                    .read<AddOrEditMomentBloc>()
                    .add(AddOrEditMomentEventSelectType(type: type)),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.type, required this.selected, required this.onTap});

  final MomentType type;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final colors = type.colors(context);

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: selected ? colors.bg : palette.surfaceAlt,
            borderRadius: BorderRadius.circular(AppRadii.pill),
            border: Border.all(
              color: selected ? colors.accent.withValues(alpha: 0.5) : Colors.transparent,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                type.icon,
                size: 16,
                color: selected ? colors.accent : palette.onSurfaceMuted,
              ),
              kSpacerWidth8,
              Text(
                type.label,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: selected ? colors.onBg : palette.onSurfaceMuted,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
