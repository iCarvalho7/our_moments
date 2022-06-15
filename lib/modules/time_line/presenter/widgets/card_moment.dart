import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nossos_momentos/modules/add_moment/domain/entities/moment_type.dart';
import 'package:nossos_momentos/modules/add_moment/presenter/bloc/add_or_edit_moment_bloc.dart';
import 'package:nossos_momentos/modules/add_moment/presenter/bloc/add_or_edit_moment_event.dart';
import 'package:nossos_momentos/modules/core/presenter/routes.dart';
import 'package:nossos_momentos/modules/core/utils/theme/app_theme.dart';
import 'package:nossos_momentos/modules/time_line/domain/entity/time_line_moment.dart';

class CardMoment extends StatelessWidget {
  final TimeLineMoment moment;

  const CardMoment({
    Key? key,
    required this.moment,
  }) : super(key: key);

  Widget get _fetchIconColorByMomentType {
    switch (moment.type) {
      case MomentType.good:
        return Assets.iconGoodMoment;
      case MomentType.bad:
        return Assets.iconBadMoment;
      case MomentType.romantic:
        return Assets.iconRomanticMoment;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, AppRoute.addMoment.tag);

        BlocProvider.of<AddOrEditMomentBloc>(context)
            .add(SetupEditMomentEvent(momentID: moment.id));
      },
      child: Container(
        margin: const EdgeInsets.all(8),
        alignment: Alignment.topCenter,
        child: Material(
          elevation: 8,
          color: Colors.transparent,
          child: Container(
            decoration: AppThemes.roundedBorder,
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _fetchIconColorByMomentType,
                    const SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: Text(
                        moment.title,
                        style: AppThemes.kLightTitleStyle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.start,
                      ),
                    )
                  ],
                ),
                const SizedBox(
                  height: 15,
                ),
                Expanded(
                  child: Text(
                    moment.body,
                    style: AppThemes.kLightBodyStyle,
                    maxLines: 5,
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
