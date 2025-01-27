import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nossos_momentos/di/injection.dart';
import 'package:nossos_momentos/modules/core/presenter/widgets/background_gradient.dart';
import 'package:nossos_momentos/modules/core/presenter/widgets/loading_effect.dart';
import 'package:nossos_momentos/modules/core/presenter/widgets/primary_app_bar.dart';
import 'package:nossos_momentos/modules/core/utils/theme/app_theme.dart';
import 'package:nossos_momentos/modules/moment/domain/entities/moment.dart';
import 'package:nossos_momentos/modules/time_line/domain/entity/time_line.dart';
import 'package:nossos_momentos/modules/time_line/presenter/bloc/time_line_bloc.dart';
import 'package:nossos_momentos/modules/time_line/presenter/widgets/card_moment.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:timeline_tile/timeline_tile.dart';

import '../../../core/presenter/routes.dart';
import '../../../core/presenter/widgets/custom_delete_dialog.dart';
import '../../../moment/presenter/bloc/add_or_edit_moment_bloc.dart';

class TimeLinePage extends StatefulWidget {
  const TimeLinePage({super.key});

  @override
  State<TimeLinePage> createState() => _TimeLinePageState();
}

class _TimeLinePageState extends State<TimeLinePage> {
  @override
  Widget build(BuildContext context) {
    final timeLine = ModalRoute.of(context)?.settings.arguments as TimeLine?;

    return BlocProvider<TimeLineBloc>(
      create: (_) => getIt<TimeLineBloc>()..add(TimeLineEventInit(timeLine: timeLine)),
      child: BlocBuilder<TimeLineBloc, TimeLineState>(
        builder: (context, state) {
          return Stack(
            children: [
              Scaffold(
                appBar: PrimaryAppBar(
                  title: Strings.appName,
                  background: BackgroundGradient(),
                  icons: [
                    IconButton(
                      icon: Icon(Icons.add_circle_outline),
                      onPressed: () => _goToAddMoment(context),
                    ),
                    IconButton(
                      icon: Icon(Icons.filter_alt_outlined),
                      onPressed: () => _showDatePicker(context, state),
                    ),
                    IconButton(
                      icon: Icon(Icons.settings_outlined),
                      onPressed: () {},
                    ),
                  ],
                ),
                body: state is TimeLineStateLoading ? _buildLoadingState() : _buildTimeLine(state),
              ),
            ],
          );
        },
      ),
    );
  }

  void _goToAddMoment(BuildContext context) {
    Navigator.pushNamed(context, AppRoute.addMoment.tag).then(
      (_) => context.read<TimeLineBloc>().add(TimeLineEventChangeDate()),
    );

    final timelineId = context.read<TimeLineBloc>().timelineId;

    BlocProvider.of<AddOrEditMomentBloc>(context).add(SetupAddMomentEvent(timelineId: timelineId));
  }

  void _showDatePicker(BuildContext context, TimeLineState state) {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return SfDateRangePicker(
          view: DateRangePickerView.year,
          selectionMode: DateRangePickerSelectionMode.range,
          toggleDaySelection: true,
          showNavigationArrow: true,
          allowViewNavigation: false,
          showActionButtons: true,
          initialDisplayDate: state.startDate,
          initialSelectedRange: PickerDateRange(
            state.startDate,
            state.endDate,
          ),
          onSubmit: (date) => _onCalendarSubmit(date, context),
        );
      },
    );
  }

  void _onCalendarSubmit(Object? date, BuildContext context) {
    if (date is PickerDateRange) {
      if (date.endDate != null && date.startDate != null) {
        context.read<TimeLineBloc>().add(
              TimeLineEventChangeDate(
                startDate: date.startDate,
                endDate: date.endDate,
              ),
            );
        Navigator.pop(context);
      }
    }
  }

  Widget _buildTimeLine(TimeLineState state) {
    final momentsList = <Moment>[];

    if (state is TimeLineStateLoaded) {
      momentsList.addAll(state.momentsList);
    }

    if (momentsList.isEmpty) {
      return Center(
        child: Text('Não encontrei momentos nessa data :('),
      );
    }

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: ListView.builder(
        itemCount: momentsList.length,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (parentContext, index) {
          return GestureDetector(
            onLongPress: () => _showDeleteMomentDialog(
              parentContext,
              momentsList[index].id,
            ),
            child: TimelineTile(
              alignment: TimelineAlign.manual,
              lineXY: 0.08,
              beforeLineStyle: const LineStyle(color: AppColors.timeLineColor),
              afterLineStyle: const LineStyle(color: AppColors.timeLineColor),
              indicatorStyle: IndicatorStyle(
                height: 15,
                width: 15,
                color: Colors.transparent,
                indicator: const _CircularIndicator(),
              ),
              endChild: CardMoment(moment: momentsList[index]),
              // startChild: Text(
              //   momentsList[index].dateTimeFormatted,
              //   textAlign: TextAlign.center,
              //   style: Theme.of(context).textTheme.titleMedium,
              // ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return Column(
      children: [
        ListView.builder(
          itemCount: 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            return LoadingEffect(
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: 200,
                color: Colors.white,
                margin: const EdgeInsets.symmetric(vertical: 10),
              ),
            );
          },
        ),
      ],
    );
  }

  void _showDeleteMomentDialog(BuildContext context, String momentId) {
    CustomDeleteDialog.show(
      context,
      text: 'Você tem certeza que deseja remover esse momento das areias do tempo?',
      onTapPositive: () {
        context.read<TimeLineBloc>().add(TimeLineEventDeleteMoment(momentId: momentId));
        Navigator.pop(context);
      },
    );
  }
}

class _CircularIndicator extends StatelessWidget {
  const _CircularIndicator();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppThemes.circularBorder.copyWith(
        color: AppColors.timeLineColor,
      ),
    );
  }
}