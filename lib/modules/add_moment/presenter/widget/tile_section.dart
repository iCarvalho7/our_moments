import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nossos_momentos/modules/add_moment/presenter/bloc/add_or_edit_moment_bloc.dart';
import 'package:nossos_momentos/modules/add_moment/presenter/bloc/add_or_edit_moment_event.dart';
import 'package:nossos_momentos/modules/core/utils/theme/app_theme.dart';

class TitleSection extends StatelessWidget {
  const TitleSection({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      textInputAction: TextInputAction.next,
      textCapitalization: TextCapitalization.sentences,
      style: AppThemes.kLightTitleStyle,
      cursorColor: Colors.black,
      decoration: InputDecoration(
        floatingLabelBehavior: FloatingLabelBehavior.never,
        alignLabelWithHint: true,
        labelText: 'Aquele em que...',
        floatingLabelStyle: AppThemes.kLightTitleStyle,
        labelStyle: AppThemes.kLightTitleStyle,
        border: InputBorder.none,
      ),
      onChanged: (title) {
        BlocProvider.of<AddOrEditMomentBloc>(context)
            .add(AddOrEditMomentEventTypeTitle(title: title));
      },
    );
  }
}
