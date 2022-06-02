import 'package:flutter/material.dart';
import 'package:nossos_momentos/modules/core/presenter/routes.dart';
import 'package:nossos_momentos/modules/core/utils/theme/app_theme.dart';

class CardAddMoment extends StatelessWidget {
  const CardAddMoment({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, AppRoute.addMoment.tag);
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
            padding: const EdgeInsets.all(20),
            child: Text(
              'Adcionar Momento ...',
              style: AppThemes.kBodyLargeLineStyle,
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
