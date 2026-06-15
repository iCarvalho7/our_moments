import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nossos_momentos/modules/core/utils/theme/app_theme.dart';
import 'package:nossos_momentos/modules/moment/domain/entities/moment.dart';
import 'package:nossos_momentos/modules/time_line/presenter/bloc/time_line_bloc.dart';

import '../../../core/presenter/routes.dart';
import '../../../moment/presenter/bloc/add_or_edit_moment_bloc.dart';

class CardMoment extends StatelessWidget {
  final Moment moment;

  const CardMoment({super.key, required this.moment});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colors = moment.type.colors(context);

    return GestureDetector(
      onTap: () {
        final timeLineBloc = context.read<TimeLineBloc>();
        Navigator.pushNamed(context, AppRoute.addMoment.tag).then(
          (_) => timeLineBloc.add(TimeLineEventChangeDate()),
        );

        BlocProvider.of<AddOrEditMomentBloc>(context).add(SetupEditMomentEvent(moment: moment));
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        padding: const EdgeInsets.all(18.0),
        decoration: BoxDecoration(
          color: colors.bg,
          borderRadius: BorderRadius.circular(AppRadii.card),
          boxShadow: AppShadows.soft(context),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: colors.accent.withValues(alpha: 0.18),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(moment.type.icon, size: 20, color: colors.accent),
                ),
                kSpacerWidth12,
                Expanded(
                  child: Text(
                    moment.title,
                    style: textTheme.headlineSmall?.copyWith(color: colors.onBg),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            kSpacerHeight12,
            Text(
              moment.body,
              style: textTheme.bodyMedium?.copyWith(color: colors.onBg.withValues(alpha: 0.85)),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            kSpacerHeight12,
            Align(
              alignment: Alignment.bottomRight,
              child: Text(
                moment.dateTimeFormatted,
                style: textTheme.bodySmall?.copyWith(color: colors.onBg.withValues(alpha: 0.6)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
