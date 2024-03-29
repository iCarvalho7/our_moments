import 'package:flutter/material.dart';

import '../../moment/presenter/page/add_moment_page.dart';
import '../../stories/presenter/page/story_page.dart';
import '../../time_line/presenter/page/time_line_page.dart';

enum AppRoute {
  timeLine(
    '//time_line',
    TimeLinePage(),
  ),
  addMoment(
    '//add_moment',
    AddOrEditMomentPage(),
  ),
  story(
    '//story',
    StoryPage(),
  );

  final String tag;
  final Widget page;

  const AppRoute(this.tag, this.page);

  static Map<String, WidgetBuilder> get allRoutes {
    final map = <String, WidgetBuilder>{};

    AppRoute.values.asMap().forEach((index, value) {
      map.addAll(<String, WidgetBuilder>{value.tag: (_) => value.page});
    });

    return map;
  }
}
