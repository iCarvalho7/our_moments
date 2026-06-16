import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/utils/theme/app_theme.dart';
import '../../domain/entities/moment_type.dart';
import '../bloc/add_or_edit_moment_bloc.dart';

/// Segmented selector for the moment "mood" (Ruim / Romântico / Bom), shown at
/// the top of the detail sheet. The selected segment animates into the type's
/// own color set.
class MomentTypeSelector extends StatelessWidget {
  const MomentTypeSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return BlocBuilder<AddOrEditMomentBloc, AddOrEditMomentState>(
      buildWhen: (p, c) => p.moment.type != c.moment.type,
      builder: (context, state) {
        return Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: palette.surfaceAlt,
            borderRadius: BorderRadius.circular(AppRadii.pill),
          ),
          child: Row(
            children: MomentType.values.map((type) {
              return Expanded(
                child: _Segment(
                  type: type,
                  selected: state.moment.type == type,
                  onTap: () => context
                      .read<AddOrEditMomentBloc>()
                      .add(AddOrEditMomentEventSelectType(type: type)),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}

class _Segment extends StatelessWidget {
  const _Segment({
    required this.type,
    required this.selected,
    required this.onTap,
  });

  final MomentType type;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final colors = type.colors(context);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected ? colors.bg : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadii.pill),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              type.icon,
              size: 18,
              color: selected ? colors.accent : palette.onSurfaceMuted,
            ),
            kSpacerWidth8,
            Flexible(
              child: Text(
                type.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: selected ? colors.onBg : palette.onSurfaceMuted,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
