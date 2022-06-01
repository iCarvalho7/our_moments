import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nossos_momentos/modules/core/utils/theme/app_theme.dart';
import 'package:nossos_momentos/modules/time_line/domain/entities/moment.dart';
import 'package:nossos_momentos/modules/time_line/domain/entities/moment_type.dart';

class CardMoment extends StatelessWidget {
  final Moment moment;

  const CardMoment({
    Key? key,
    required this.moment,
  }) : super(key: key);

  Icon get _fetchIconColorByMomentType {
    switch (moment.type) {
      case MomentType.good:
        return const Icon(
          Icons.done,
          color: Colors.green,
        );
      case MomentType.bad:
        return const Icon(
          Icons.close,
          color: Colors.red,
        );
      case MomentType.romantic:
        return const Icon(
          CupertinoIcons.heart_fill,
          color: Colors.pinkAccent,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 8,
      child: Container(
        decoration: AppThemes.roundedBorder,
        child: Column(
          children: [
            Row(
              children: [
                _fetchIconColorByMomentType,
                Text(
                  moment.title,
                  style: AppThemes.kTitleStyle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                )
              ],
            ),
            Text(
              moment.body,
              style: AppThemes.kBodyStyle,
              maxLines: 5,
              overflow: TextOverflow.ellipsis,
            )
          ],
        ),
      ),
    );
  }
}
