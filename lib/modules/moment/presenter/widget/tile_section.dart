import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/add_or_edit_moment_bloc.dart';
import '../../../core/utils/theme/app_theme.dart';

class TitleSection extends StatelessWidget {
  const TitleSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AddOrEditMomentBloc, AddOrEditMomentState>(
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextFormField(
            textInputAction: TextInputAction.next,
            textCapitalization: TextCapitalization.sentences,
            style: AppThemes.kLightTitleStyle,
            cursorColor: Colors.black,
            initialValue: state.moment.title,
            decoration: InputDecoration(
              isDense: true,
              floatingLabelBehavior: FloatingLabelBehavior.never,
              alignLabelWithHint: true,
              labelText: 'Aquele em que...',
              floatingLabelStyle: AppThemes.kLightTitleStyle,
              labelStyle: AppThemes.kLightTitleStyle,
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero
            ),
            onChanged: (title) {
              BlocProvider.of<AddOrEditMomentBloc>(context)
                  .add(AddOrEditMomentEventTypeTitle(title: title));
            },
          ),
        );
      },
    );
  }
}
