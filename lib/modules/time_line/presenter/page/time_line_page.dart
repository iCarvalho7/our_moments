import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nossos_momentos/dependencie_injection/injection.dart';
import 'package:nossos_momentos/modules/core/presenter/widgets/loading_effect.dart';
import 'package:nossos_momentos/modules/core/utils/theme/app_theme.dart';
import 'package:nossos_momentos/modules/time_line/presenter/bloc/time_line_bloc.dart';
import 'package:nossos_momentos/modules/time_line/presenter/bloc/time_line_events.dart';
import 'package:nossos_momentos/modules/time_line/presenter/bloc/time_line_state.dart';
import 'package:nossos_momentos/modules/time_line/presenter/widgets/card_add_moment.dart';
import 'package:nossos_momentos/modules/time_line/presenter/widgets/card_moment.dart';
import 'package:nossos_momentos/modules/time_line/presenter/widgets/year_slider.dart';
import 'package:timelines/timelines.dart';

class TimeLinePage extends StatefulWidget {
  const TimeLinePage({Key? key}) : super(key: key);

  @override
  State<TimeLinePage> createState() => _TimeLinePageState();
}

class _TimeLinePageState extends State<TimeLinePage> {
  final timeLineBloc = getIt<TimeLineBloc>()..add(const TimeLineEventInit());

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: BlocProvider(
              create: (_) => timeLineBloc,
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
                                  TimeLineEventChangeDate(
                                    year: year,
                                  ),
                                },
                                carrouselItems: TimeLineBloc.enabledYears,
                              ),
                              TextSlider(
                                onChangeItem: (month) => {
                                  timeLineBloc.add(
                                    TimeLineEventChangeDate(
                                      month: month,
                                    ),
                                  )
                                },
                                carrouselItems: TimeLineBloc.monthsName,
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      if (state is TimeLineStateEmpty)
                        _buildEmptyState()
                      else if (state is TimeLineStateLoaded)
                        _buildTimeLinePage(state)
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

  Widget _buildTimeLinePage(TimeLineStateLoaded state) {
    return FixedTimeline.tileBuilder(
      theme: TimelineThemeData(
        indicatorTheme: defaultIndicator,
      ),
      builder: TimelineTileBuilder(
        itemCount: state.momentsList.length + 1,
        startConnectorBuilder: (_, index) => pinkLineConnector,
        endConnectorBuilder: (_, index) => pinkLineConnector,
        indicatorBuilder: (_, index) {
          if (_isFirstItem(index)) {
            return Assets.iconAddMoments;
          }
          return Indicator.dot(color: AppColors.romanticColor);
        },
        contentsBuilder: (context, index) {
          if (_isFirstItem(index)) {
            return const CardAddMoment();
          }
          return CardMoment(moment: state.momentsList[index]);
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return FixedTimeline.tileBuilder(
      theme: TimelineThemeData(
        nodePosition: 0,
        indicatorPosition: 0.01,
        indicatorTheme: defaultIndicator,
      ),
      builder: TimelineTileBuilder(
        itemExtent: MediaQuery.of(context).size.height,
        itemCount: 1,
        startConnectorBuilder: (_, __) => pinkLineConnector,
        endConnectorBuilder: (_, __) => pinkLineConnector,
        indicatorBuilder: (_, __) => Assets.iconAddMoments,
        contentsBuilder: (context, index) => const CardAddMoment(),
      ),
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

  SolidLineConnector get pinkLineConnector => const SolidLineConnector(
        color: AppColors.romanticColor,
        thickness: 3,
      );

  IndicatorThemeData get defaultIndicator => const IndicatorThemeData(
        color: Colors.pink,
        position: 3,
      );

  bool _isFirstItem(int index) => index == 0;
}
