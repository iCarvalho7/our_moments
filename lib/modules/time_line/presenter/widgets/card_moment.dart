import 'package:flutter/material.dart';
import 'package:nossos_momentos/modules/add_moment/domain/entities/moment_type.dart';
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
    return Container(
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
                  const SizedBox(width: 10,),
                  Text(
                    moment.title,
                    style: AppThemes.kLightTitleStyle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.right,
                  )
                ],
              ),
              const SizedBox(height: 20,),
              Text(
                moment.body,
                style: AppThemes.kLightBodyStyle,
                maxLines: 5,
                overflow: TextOverflow.ellipsis,
              )
            ],
          ),
        ),
      ),
    );
  }
}
