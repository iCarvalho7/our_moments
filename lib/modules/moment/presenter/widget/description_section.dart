import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/add_or_edit_moment_bloc.dart';
import '../../../core/utils/theme/app_theme.dart';

class DescriptionSection extends StatelessWidget {
  final String? bodyText;

  const DescriptionSection({Key? key, this.bodyText}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      textInputAction: TextInputAction.newline,
      keyboardType: TextInputType.multiline,
      maxLines: null,
      textCapitalization: TextCapitalization.sentences,
      style: AppThemes.kLightBodyStyle,
      cursorColor: Colors.black,
      initialValue: bodyText,
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
