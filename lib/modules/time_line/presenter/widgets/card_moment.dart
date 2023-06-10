import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nossos_momentos/modules/moment/domain/entities/moment.dart';
import 'package:nossos_momentos/modules/time_line/presenter/bloc/time_line_bloc.dart';
import '../../../moment/domain/entities/moment_type.dart';
import '../../../moment/presenter/bloc/add_or_edit_moment_bloc.dart';
import '../../../core/presenter/routes.dart';
import '../../../core/utils/theme/app_theme.dart';

class CardMoment extends StatelessWidget {
  final Moment moment;

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
        Navigator.pushNamed(context, AppRoute.addMoment.tag).then(
          (_) => context.read<TimeLineBloc>().add(const TimeLineEventChangeDate()),
        );

        BlocProvider.of<AddOrEditMomentBloc>(context).add(SetupEditMomentEvent(moment: moment));
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
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.start,
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 15),
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
