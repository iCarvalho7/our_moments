import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/utils/theme/app_theme.dart';
import '../bloc/add_or_edit_moment_bloc.dart';

class DescriptionSection extends StatelessWidget {

  const DescriptionSection({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return BlocBuilder<AddOrEditMomentBloc, AddOrEditMomentState>(
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: palette.surfaceAlt,
              borderRadius: BorderRadius.circular(AppRadii.input),
            ),
            child: TextFormField(
              textInputAction: TextInputAction.newline,
              keyboardType: TextInputType.multiline,
              minLines: 5,
              maxLines: null,
              textCapitalization: TextCapitalization.sentences,
              style: Theme.of(context).textTheme.bodyLarge,
              cursorColor: palette.primary,
              initialValue: state.moment.body,
              decoration: InputDecoration(
                filled: false,
                isDense: true,
                alignLabelWithHint: true,
                hintText: 'Descreva em detalhes (ou não) esse momento',
                hintStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: palette.onSurfaceMuted,
                    ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
              onChanged: (bodyText) {
                BlocProvider.of<AddOrEditMomentBloc>(context)
                    .add(AddOrEditMomentEvenTypeBodyText(bodyText: bodyText));
              },
            ),
          ),
        );
      },
    );
  }
}
