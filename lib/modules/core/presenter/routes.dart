import 'package:flutter/material.dart';
import 'package:nossos_momentos/modules/login/presentation/page/login_page.dart';
import 'package:nossos_momentos/modules/settings/presentation/page/account_settings_page.dart';
import 'package:nossos_momentos/modules/settings/presentation/page/settings_page.dart';
import 'package:nossos_momentos/modules/signup/presentation/page/sign_up_page.dart';
import 'package:nossos_momentos/modules/time_line/presenter/page/all_timelines_map_page.dart';
import 'package:nossos_momentos/modules/time_line/presenter/page/new_select_time_line_page.dart';
import 'package:nossos_momentos/modules/time_line/presenter/page/select_time_line_page.dart';

import '../../moment/presenter/page/add_moment_page.dart';
import '../../moment/presenter/page/location_picker_page.dart';
import '../../moment/presenter/page/share_moment_page.dart';
import '../../premium/presenter/page/paywall_page.dart';
import '../../stories/presenter/page/story_page.dart';
import '../../time_line/bucket_list/presenter/page/bucket_list_page.dart';
import '../../time_line/presenter/page/couple_features_hub_page.dart';
import '../../time_line/presenter/page/couple_stats_page.dart';
import '../../time_line/presenter/page/moments_map_page.dart';
import '../../time_line/presenter/page/on_this_day_page.dart';
import '../../time_line/presenter/page/time_line_page.dart';
import '../../time_line/presenter/page/year_in_review_page.dart';
import '../../time_line/special_dates/presenter/page/special_dates_page.dart';
import '../../time_line/time_capsule/presenter/page/time_capsule_page.dart';

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
    SelectTimeLinePage(),
  ),
  newSelectTimeLine(
    '//new_select_time_line',
    NewSelectTimeLinePage(),
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
  ),
  settings(
    '//settings',
    SettingsPage(),
  ),
  allTimelinesMap(
    '//all_timelines_map',
    AllTimelinesMapPage(),
  ),
  accountSettings(
    '//account_settings',
    AccountSettingsPage(),
  ),
  onThisDay(
    '//on_this_day',
    OnThisDayPage(),
  ),
  bucketList(
    '//bucket_list',
    BucketListPage(),
  ),
  specialDates(
    '//special_dates',
    SpecialDatesPage(),
  ),
  timeCapsule(
    '//time_capsule',
    TimeCapsulePage(),
  ),
  coupleStats(
    '//couple_stats',
    CoupleStatsPage(),
  ),
  shareMoment(
    '//share_moment',
    ShareMomentPage(),
  ),
  coupleFeaturesHub(
    '//couple_features_hub',
    CoupleFeaturesHubPage(),
  ),
  momentsMap(
    '//moments_map',
    MomentsMapPage(),
  ),
  yearInReview(
    '//year_in_review',
    YearInReviewPage(),
  ),
  paywall(
    '//paywall',
    PaywallPage(),
  ),
  locationPicker(
    '//location_picker',
    LocationPickerPage(),
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
