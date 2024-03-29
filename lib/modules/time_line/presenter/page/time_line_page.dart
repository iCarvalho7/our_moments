import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nossos_momentos/di/injection.dart';
import 'package:nossos_momentos/modules/core/presenter/widgets/loading_effect.dart';
import 'package:nossos_momentos/modules/core/utils/theme/app_theme.dart';
import 'package:nossos_momentos/modules/moment/domain/entities/moment.dart';
import 'package:nossos_momentos/modules/time_line/presenter/bloc/time_line_bloc.dart';
import 'package:nossos_momentos/modules/time_line/presenter/widgets/card_add_moment.dart';
import 'package:nossos_momentos/modules/time_line/presenter/widgets/card_moment.dart';
import 'package:nossos_momentos/modules/time_line/presenter/widgets/text_slider.dart';
import 'package:time_machine/time_machine.dart';
import 'package:timeline_tile/timeline_tile.dart';

import '../../../core/presenter/widgets/custom_delete_dialog.dart';

class TimeLinePage extends StatefulWidget {
  const TimeLinePage({super.key});

  @override
  State<TimeLinePage> createState() => _TimeLinePageState();
}

class _TimeLinePageState extends State<TimeLinePage> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider<TimeLineBloc>(
      create: (_) => getIt<TimeLineBloc>()..add(const TimeLineEventInit()),
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            elevation: 0,
            centerTitle: true,
            title: const Text(Strings.appName),
            backgroundColor: AppColors.secondary,
          ),
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [0, 0.3],
                colors: [
                  AppColors.secondary,
                  Colors.white,
                ],
              ),
            ),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: BlocBuilder<TimeLineBloc, TimeLineState>(
                builder: (context, state) {
                  return Column(
                    children: [
                      _TimeLineHeader(state: state),
                      if (state is TimeLineStateLoading) ...[
                        _buildLoadingState(),
                      ] else ...[
                        _buildTimeLine(state),
                      ],
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  ListView _buildTimeLine(TimeLineState state) {
    final momentsList = <Moment>[];

    if (state is TimeLineStateLoaded) {
      momentsList.addAll(state.momentsList);
    }

    return ListView.builder(
      itemCount: momentsList.isEmpty ? 60 : momentsList.length + 1,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (parentContext, index) {
        return GestureDetector(
          onLongPress: () => momentsList.isNotEmpty && index != 0
              ? _showDeleteMomentDialog(
                  parentContext,
                  momentsList[index - 1].id,
                )
              : null,
          child: TimelineTile(
            alignment: TimelineAlign.manual,
            lineXY: 0.125,
            isFirst: index == 0,
            beforeLineStyle: const LineStyle(color: AppColors.timeLineColor),
            afterLineStyle: const LineStyle(color: AppColors.timeLineColor),
            indicatorStyle: IndicatorStyle(
              height: index == 0
                  ? 50
                  : momentsList.isEmpty
                      ? 4
                      : 15,
              width: index == 0
                  ? 50
                  : momentsList.isEmpty
                      ? 4
                      : 15,
              color: AppColors.timeLineColor,
              indicator: index == 0
                  ? Assets.iconAddMoments
                  : momentsList.isEmpty
                      ? Container(color: AppColors.timeLineColor)
                      : const _CircularIndicator(),
            ),
            endChild: index == 0
                ? const CardAddMoment()
                : momentsList.isEmpty
                    ? const SizedBox(height: 10)
                    : CardMoment(moment: momentsList[index - 1]),
            startChild: index == 0 || momentsList.isEmpty
                ? const SizedBox.shrink()
                : Text(
                    momentsList[index - 1].dateTimeFormatted,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
          ),
        );
      },
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
  const _CircularIndicator({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppThemes.circularBorder.copyWith(
        color: AppColors.timeLineColor,
      ),
    );
  }
}

class _TimeLineHeader extends StatelessWidget {
  const _TimeLineHeader({required this.state});

  final TimeLineState state;

  @override
  Widget build(BuildContext context) {
    final monthIndex = TimeLineBloc.monthsName.indexOf(state.month);
    final yearIndex = TimeLineBloc.enabledYears.indexOf(state.year);

    return Padding(
      padding: const EdgeInsets.only(left: 20, bottom: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _CalendarCard(),
          Column(
            children: [
              if (yearIndex != -1) ...[
                TextSlider(
                  carrouselItems: TimeLineBloc.enabledYears,
                  selectedIndex: yearIndex,
                  onChangeItem: (year) =>
                      context.read<TimeLineBloc>().add(TimeLineEventChangeDate(year: year)),
                ),
              ],
              if (monthIndex != -1) ...[
                Row(
                  children: [
                    TextSlider(
                      carrouselItems: TimeLineBloc.monthsName,
                      isEnabled: context.read<TimeLineBloc>().state.isMonthEnabled,
                      selectedIndex: monthIndex,
                      onChangeItem: (month) =>
                          context.read<TimeLineBloc>().add(TimeLineEventChangeDate(month: month)),
                    ),
                    IconButton(
                      icon: Icon(
                        context.read<TimeLineBloc>().state.isMonthEnabled
                            ? Icons.visibility
                            : Icons.visibility_off,
                        size: 30,
                      ),
                      onPressed: () =>
                          context.read<TimeLineBloc>().add(const TimeLineEventChangeEyeToggle()),
                    ),
                  ],
                ),
              ]
            ],
          ),
        ],
      ),
    );
  }
}

class _CalendarCard extends StatelessWidget {
  _CalendarCard({Key? key}) : super(key: key);

  final Period time = LocalDate.dateTime(DateTime(2019, 5, 22)).periodSince(LocalDate.today());

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const Positioned(
          left: 10,
          child: _CalendarTopCardWidget(),
        ),
        const Positioned(
          right: 10,
          child: _CalendarTopCardWidget(),
        ),
        Card(
          elevation: 5,
          color: AppColors.calendarColor,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 4,
            ),
            child: Text(
              '${time.years.abs()} Anos\n${time.months.abs()} Meses',
              style: Theme.of(context).appBarTheme.titleTextStyle,
            ),
          ),
        ),
      ],
    );
  }
}

class _CalendarTopCardWidget extends StatelessWidget {
  const _CalendarTopCardWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 15,
      height: 10,
      decoration: BoxDecoration(
        color: AppColors.calendarColor,
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }
}
