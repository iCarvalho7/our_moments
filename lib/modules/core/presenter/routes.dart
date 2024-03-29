import 'package:flutter/material.dart';
import 'package:nossos_momentos/modules/login/presentation/page/login_page.dart';
import 'package:nossos_momentos/modules/signup/presentation/page/sign_up_page.dart';
import 'package:nossos_momentos/modules/time_line/presenter/page/create_time_line_page.dart';

import '../../moment/presenter/page/add_moment_page.dart';
import '../../stories/presenter/page/story_page.dart';
import '../../time_line/presenter/page/time_line_page.dart';

enum AppRoute {
  login(
    '//login',
    LoginPage()
  ),
  signup(
      '//register_user',
      SignUpPage()
  ),
  createTimeLine(
    '//create_time_line',
    CreateTimeLinePage(),
  ),
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
