import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/utils/theme/app_theme.dart';
import '../bloc/add_or_edit_moment_bloc.dart';

class LocationSection extends StatelessWidget {
  const LocationSection({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return BlocBuilder<AddOrEditMomentBloc, AddOrEditMomentState>(
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: palette.surfaceAlt,
              borderRadius: BorderRadius.circular(AppRadii.input),
            ),
            child: TextFormField(
              initialValue: state.moment.locationName,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
              style: Theme.of(context).textTheme.bodyLarge,
              cursorColor: palette.primary,
              decoration: InputDecoration(
                filled: false,
                isDense: true,
                icon: Icon(Icons.place_outlined, color: palette.onSurfaceMuted, size: 20),
                hintText: 'Ex: Praia de Copacabana',
                hintStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: palette.onSurfaceMuted,
                    ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 16),
              ),
              onChanged: (value) => context
                  .read<AddOrEditMomentBloc>()
                  .add(AddOrEditMomentEventTypeLocation(location: value)),
            ),
          ),
        );
      },
    );
  }
}
