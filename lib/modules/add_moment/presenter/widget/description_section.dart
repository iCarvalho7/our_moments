import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nossos_momentos/modules/add_moment/presenter/bloc/add_or_edit_moment_bloc.dart';
import 'package:nossos_momentos/modules/add_moment/presenter/bloc/add_or_edit_moment_event.dart';
import 'package:nossos_momentos/modules/core/utils/theme/app_theme.dart';

class DescriptionSection extends StatelessWidget {
  const DescriptionSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      textInputAction: TextInputAction.newline,
      keyboardType: TextInputType.multiline,
      maxLines: 200,
      textCapitalization: TextCapitalization.sentences,
      style: AppThemes.kLightBodyStyle,
      cursorColor: Colors.black,
      decoration: InputDecoration(
        alignLabelWithHint: true,
        labelText: '...',
        floatingLabelStyle: AppThemes.kLightBodyStyle,
        labelStyle: AppThemes.kLightBodyStyle,
        border: InputBorder.none,
      ),
      onChanged: (bodyText) {
        BlocProvider.of<AddOrEditMomentBloc>(context)
            .add(AddOrEditMomentEvenTypeBodyText(bodyText: bodyText));
      },
    );
  }
}
