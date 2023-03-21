import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/presenter/routes.dart';
import '../../../core/utils/theme/app_theme.dart';
import '../../../moment/presenter/bloc/add_or_edit_moment_bloc.dart';

class CardAddMoment extends StatelessWidget {
  const CardAddMoment({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, AppRoute.addMoment.tag);

        BlocProvider.of<AddOrEditMomentBloc>(context)
            .add(const SetupAddMomentEvent());
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        alignment: Alignment.topCenter,
        child: Material(
          elevation: 8,
          color: Colors.transparent,
          child: Container(
            decoration: AppThemes.roundedBorder,
            width: MediaQuery.of(context).size.width,
            padding: const EdgeInsets.all(15),
            child: Text(
              'Adcionar Momento ...',
              style: AppThemes.kLightHeadLineStyle,
              maxLines: 1,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ),
    );
  }
}
