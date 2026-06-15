import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/presenter/routes.dart';
import '../../../core/presenter/widgets/app_card.dart';
import '../../../core/utils/theme/app_theme.dart';
import '../../../moment/presenter/bloc/add_or_edit_moment_bloc.dart';
import '../bloc/time_line_bloc.dart';

class CardAddMoment extends StatelessWidget {
  const CardAddMoment({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: AppCard(
        onTap: () {
          final timeLineBloc = context.read<TimeLineBloc>();
          Navigator.pushNamed(
            context,
            AppRoute.addMoment.tag,
            arguments: timeLineBloc.timeLine.accentColor,
          ).then(
            (_) => timeLineBloc.add(TimeLineEventChangeDate()),
          );

          final timelineId = timeLineBloc.timelineId;

          BlocProvider.of<AddOrEditMomentBloc>(context)
              .add(SetupAddMomentEvent(timelineId: timelineId));
        },
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: palette.primarySoft,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.add_rounded, color: palette.primary, size: 26),
            ),
            kSpacerWidth16,
            Text(
              'Adicionar momento',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      ),
    );
  }
}
