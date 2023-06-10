import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nossos_momentos/di/injection.dart';
import 'package:nossos_momentos/modules/core/presenter/widgets/loading_effect.dart';
import 'package:nossos_momentos/modules/core/utils/theme/app_theme.dart';
import 'package:nossos_momentos/modules/time_line/presenter/bloc/time_line_bloc.dart';
import 'package:nossos_momentos/modules/time_line/presenter/widgets/card_add_moment.dart';
import 'package:nossos_momentos/modules/time_line/presenter/widgets/card_moment.dart';
import 'package:nossos_momentos/modules/time_line/presenter/widgets/text_slider.dart';
import 'package:time_machine/time_machine.dart';
import 'package:timeline_tile/timeline_tile.dart';

import '../../../core/presenter/widgets/custom_delete_dialog.dart';

class TimeLinePage extends StatefulWidget {
  const TimeLinePage({Key? key}) : super(key: key);

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
            title: Text(
              Strings.appName,
              style: Fonts.grandHotelTitle,
            ),
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
                buildWhen: (oldState, state) => state is! TimeLineStateInitial,
                builder: (context, state) {
                  return Column(
                    children: [
                      _TimeLineHeader(),
                      _buildTimeLinePage(),
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

  Widget _buildTimeLinePage() {
    return BlocBuilder<TimeLineBloc, TimeLineState>(
      builder: (context, state) {
        if (state is TimeLineStateLoaded) {
          return _buildLoadedState(state);
        }
        if (state is TimeLineStateLoading) {
          return _buildLoadingState();
        }
        if (state is TimeLineStateEmpty) {
          return _buildEmptyState(state);
        }
        return const SizedBox.shrink();
      },
    );
  }

  ListView _buildLoadedState(TimeLineStateLoaded state) {
    return ListView.builder(
      itemCount: state.momentsList.length + 1,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (parentContext, index) {
        return GestureDetector(
          onLongPress: () => _showDeleteMomentDialog(
            parentContext,
            state.momentsList[index - 1].id,
          ),
          child: TimelineTile(
            alignment: TimelineAlign.manual,
            lineXY: 0.125,
            isFirst: _isFirstItem(index),
            beforeLineStyle: const LineStyle(color: AppColors.timeLineColor),
            afterLineStyle: const LineStyle(color: AppColors.timeLineColor),
            indicatorStyle: IndicatorStyle(
              height: _isFirstItem(index) ? 50 : 15,
              width: _isFirstItem(index) ? 50 : 15,
              color: AppColors.timeLineColor,
              indicator: _isFirstItem(index) ? Assets.iconAddMoments : const _CircularIndicator(),
            ),
            endChild: _isFirstItem(index)
                ? const CardAddMoment()
                : CardMoment(moment: state.momentsList[index - 1]),
            startChild: _isFirstItem(index)
                ? const SizedBox.shrink()
                : Text(
                    state.momentsList[index - 1].dateTimeFormatted,
                    textAlign: TextAlign.center,
                    style: AppThemes.kBodyLargeLineStyle,
                  ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(TimeLineStateEmpty state) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: 55,
      itemBuilder: (context, index) {
        return TimelineTile(
          alignment: TimelineAlign.manual,
          lineXY: 0.125,
          isFirst: _isFirstItem(index),
          beforeLineStyle: const LineStyle(color: AppColors.timeLineColor),
          afterLineStyle: const LineStyle(color: AppColors.timeLineColor),
          indicatorStyle: IndicatorStyle(
            height: 50,
            width: _isFirstItem(index) ? 50 : 4,
            color: AppColors.timeLineColor,
            indicator: _isFirstItem(index)
                ? Assets.iconAddMoments
                : Container(color: AppColors.timeLineColor),
          ),
          endChild: _isFirstItem(index) ? const CardAddMoment() : const SizedBox(height: 10),
          startChild: const SizedBox.shrink(),
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
          itemBuilder: ((context, index) {
            return LoadingEffect(
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: 200,
                color: Colors.white,
                margin: const EdgeInsets.symmetric(vertical: 10),
              ),
            );
          }),
        ),
      ],
    );
  }

  bool _isFirstItem(int index) => index == 0;

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
  _TimeLineHeader({Key? key}) : super(key: key);

  final Period diff = LocalDate.dateTime(
    DateTime(2019, 5, 22),
  ).periodSince(LocalDate.today());

  @override
  Widget build(BuildContext context) {
    final state = context.read<TimeLineBloc>().state;
    final monthIndex = TimeLineBloc.monthsName.indexOf(state.month);
    final yearIndex = TimeLineBloc.enabledYears.indexOf(state.year);

    return Padding(
      padding: const EdgeInsets.only(left: 20, bottom: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _CalendarCard(time: diff),
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
  const _CalendarCard({Key? key, required this.time}) : super(key: key);

  final Period time;

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
              style: GoogleFonts.grandHotel(
                fontSize: 30,
              ),
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
