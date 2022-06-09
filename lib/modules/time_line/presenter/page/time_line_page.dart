import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nossos_momentos/modules/core/presenter/widgets/loading_effect.dart';
import 'package:nossos_momentos/modules/core/utils/theme/app_theme.dart';
import 'package:nossos_momentos/modules/time_line/presenter/bloc/time_line_bloc.dart';
import 'package:nossos_momentos/modules/time_line/presenter/bloc/time_line_events.dart';
import 'package:nossos_momentos/modules/time_line/presenter/bloc/time_line_state.dart';
import 'package:nossos_momentos/modules/time_line/presenter/widgets/card_add_moment.dart';
import 'package:nossos_momentos/modules/time_line/presenter/widgets/card_moment.dart';
import 'package:nossos_momentos/modules/time_line/presenter/widgets/year_slider.dart';
import 'package:timeline_tile/timeline_tile.dart';

class TimeLinePage extends StatefulWidget {
  const TimeLinePage({Key? key}) : super(key: key);

  @override
  State<TimeLinePage> createState() => _TimeLinePageState();
}

class _TimeLinePageState extends State<TimeLinePage> {
  @override
  Widget build(BuildContext context) {
    BlocProvider.of<TimeLineBloc>(context).add(const TimeLineEventInit());
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: BlocBuilder<TimeLineBloc, TimeLineState>(
              builder: (context, state) {
                if (state is TimeLineStateLoading) {
                  return _buildLoadingState();
                }
                return Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Assets.iconHeart,
                        Column(
                          children: [
                            TextSlider(
                              onChangeItem: (year) => {
                                BlocProvider.of<TimeLineBloc>(context).add(
                                  TimeLineEventChangeDate(
                                    year: year,
                                  ),
                                )
                              },
                              carrouselItems: TimeLineBloc.enabledYears,
                            ),
                            Row(
                              children: [
                                TextSlider(
                                  isEnabled: state.isMonthEnabled,
                                  onChangeItem: (month) => {
                                    BlocProvider.of<TimeLineBloc>(context).add(
                                      TimeLineEventChangeDate(
                                        month: month,
                                      ),
                                    )
                                  },
                                  carrouselItems: TimeLineBloc.monthsName,
                                ),
                                IconButton(
                                  icon: Icon(
                                    state.isMonthEnabled
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                    size: 40,
                                  ),
                                  onPressed: () {
                                    BlocProvider.of<TimeLineBloc>(context).add(
                                        const TimeLineEventChangeEyeToggle());

                                    BlocProvider.of<TimeLineBloc>(context)
                                        .add(const TimeLineEventChangeDate());
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    if (state is TimeLineStateEmpty)
                      _buildEmptyState(state)
                    else if (state is TimeLineStateLoaded)
                      _buildTimeLinePage(state)
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimeLinePage(TimeLineStateLoaded state) {
    return ListView.builder(
      itemCount: state.momentsList.length + 1,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        return TimelineTile(
          alignment: TimelineAlign.manual,
          lineXY: 0.125,
          beforeLineStyle: const LineStyle(
            color: AppColors.timeLineColor,
          ),
          afterLineStyle: const LineStyle(
            color: AppColors.timeLineColor,
          ),
          indicatorStyle: IndicatorStyle(
            height: _isFirstItem(index) ? 50 : 20,
            width: _isFirstItem(index) ? 50 : 20,
            color: AppColors.timeLineColor,
            indicator: _isFirstItem(index)
                ? Assets.iconAddMoments
                : Container(
                    decoration: AppThemes.circularBorder.copyWith(
                      color: AppColors.timeLineColor,
                    ),
                  ),
          ),
          endChild: _isFirstItem(index)
              ? const CardAddMoment()
              : CardMoment(moment: state.momentsList[index - 1]),
          startChild: _isFirstItem(index)
              ? const SizedBox.shrink()
              : Text(
                  state.momentsList[index - 1].dateTime,
                  textAlign: TextAlign.center,
                  style: AppThemes.kBodyLargeLineStyle,
                ),
        );
      },
    );
  }

  Widget _buildEmptyState(TimeLineStateEmpty state) {
    return TimelineTile(
      alignment: TimelineAlign.manual,
      lineXY: 0.125,
      beforeLineStyle: const LineStyle(color: AppColors.timeLineColor),
      afterLineStyle: const LineStyle(color: AppColors.timeLineColor),
      indicatorStyle: IndicatorStyle(
        height: 50,
        width: 50,
        color: AppColors.timeLineColor,
        indicator: Assets.iconAddMoments,
      ),
      endChild: const CardAddMoment(),
      startChild: const SizedBox.shrink(),
    );
  }

  Widget _buildLoadingState() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Stack(
              children: [
                Assets.iconHeart,
                const Text('...'),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                LoadingEffect(
                  child: Container(
                    width: MediaQuery.of(context).size.width / 3,
                    height: 50,
                    color: Colors.white,
                    margin: const EdgeInsets.all(10),
                  ),
                ),
                LoadingEffect(
                  child: Container(
                    width: MediaQuery.of(context).size.width / 2,
                    height: 50,
                    color: Colors.white,
                    margin: const EdgeInsets.all(10),
                  ),
                ),
              ],
            )
          ],
        ),
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
}
