import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/presenter/routes.dart';
import '../../../moment/presenter/bloc/add_or_edit_moment_bloc.dart';
import '../bloc/time_line_bloc.dart';

class CardAddMoment extends StatelessWidget {
  const CardAddMoment({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, AppRoute.addMoment.tag).then(
              (_) => context.read<TimeLineBloc>().add(TimeLineEventChangeDate()),
        );

        final timelineId = context.read<TimeLineBloc>().timelineId;

        BlocProvider.of<AddOrEditMomentBloc>(context)
            .add(SetupAddMomentEvent(timelineId: timelineId));
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        alignment: Alignment.topCenter,
        child: Material(
          elevation: 8,
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            width: MediaQuery.of(context).size.width,
            padding: const EdgeInsets.all(15),
            child: Text(
              'Adcionar Momento +',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w100,
                  ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}
