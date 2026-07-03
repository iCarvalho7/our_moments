import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:injectable/injectable.dart';

import '../core/premium/premium_feature.dart';
import '../core/premium/premium_service.dart';
import '../core/presenter/routes.dart';
import 'domain/repository/notification_repository.dart';
import 'infra/data_source/local_notification_data_source.dart';

/// Orchestrates the premium "Neste dia" daily reminder: premium gating,
/// preference persistence, scheduling, and notification-tap routing.
///
/// Trade-off (documented): a purely local schedule cannot know, at fire time,
/// whether the couple actually has a memory for that exact day — that data
/// lives in Firestore behind auth and a query. So the reminder uses a generic,
/// actionable PT-BR message and the tap opens the timeline (where the "Neste
/// dia" screen and its memory logic live).
@lazySingleton
class NotificationService {
  final NotificationRepository _repository;
  final PremiumService _premiumService;

  NotificationService(this._repository, this._premiumService);

  /// Shared navigator key so a notification tap can navigate without a
  /// `BuildContext`. Wired into `MaterialApp.navigatorKey` in `main.dart`.
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  static const int _reminderHour = 9;
  static const int _reminderMinute = 0;

  static const String _title = 'Neste dia 💜';
  static const String _body =
      'Vocês podem ter uma memória de hoje em outros anos. Toque para reviver.';

  /// Initializes the plugin and routes taps. Call once at startup. No-op on web
  /// (the plugin is mobile/desktop only).
  Future<void> init() async {
    if (kIsWeb) return;
    await _repository.init(onTap: _onNotificationTap);
    await _handleLaunchPayload();
  }

  /// Handles a tap while the app is running (foreground/background-resume).
  void _onNotificationTap(String? payload) {
    if (payload == kOnThisDayPayload || payload == kCoupleReminderPayload) {
      _routeToOnThisDay();
    }
  }

  /// Schedules a one-shot couple reminder (special date / time capsule) at
  /// [when]. No-op on web or when [when] is already in the past. Re-using a
  /// [notificationId] reschedules it.
  Future<void> scheduleSpecialDate({
    required int notificationId,
    required String title,
    required String body,
    required DateTime when,
  }) async {
    if (kIsWeb) return;
    if (!when.isAfter(DateTime.now())) return;

    // The plugin needs OS permission to actually deliver; request lazily.
    await _repository.requestPermission();
    await _repository.scheduleReminderAt(
      id: notificationId,
      when: when,
      title: title,
      body: body,
    );
  }

  /// Cancels a previously scheduled one-shot reminder by [notificationId].
  Future<void> cancel(int notificationId) async {
    if (kIsWeb) return;
    await _repository.cancelReminder(notificationId);
  }

  /// Derives a stable, positive notification id from a Firestore document id so
  /// the same doc always maps to the same OS notification (cancel/reschedule).
  static int notificationIdFor(String docId) => docId.hashCode & 0x7fffffff;

  /// Next occurrence of a (possibly yearly-recurring) date at [hour]:[minute],
  /// counting from [from]. Keeps the original month/day, advancing the year
  /// until the result is in the future ("this year or next year").
  static DateTime nextYearlyOccurrence(
    DateTime date, {
    int hour = _reminderHour,
    int minute = _reminderMinute,
    DateTime? from,
  }) {
    final now = from ?? DateTime.now();
    var year = now.year;
    var candidate = _safeDate(year, date.month, date.day, hour, minute);
    if (!candidate.isAfter(now)) {
      candidate = _safeDate(year + 1, date.month, date.day, hour, minute);
    }
    return candidate;
  }

  /// Builds a DateTime, clamping the day to the month's last day (handles
  /// Feb 29 on non-leap years).
  static DateTime _safeDate(int year, int month, int day, int hour, int minute) {
    final lastDay = DateTime(year, month + 1, 0).day;
    return DateTime(year, month, day > lastDay ? lastDay : day, hour, minute);
  }

  /// Reconciles the OS schedule with the current premium status + user
  /// preference. Premium + enabled → (re)schedule; otherwise → cancel. Called
  /// at startup and after premium/preference changes.
  Future<void> syncSchedule() async {
    if (kIsWeb) return;

    final enabled = await _repository.isReminderEnabled();
    final allowed = _premiumService.can(PremiumFeature.onThisDayPush);

    if (enabled && allowed) {
      await _repository.scheduleDailyReminder(
        hour: _reminderHour,
        minute: _reminderMinute,
        title: _title,
        body: _body,
      );
    } else {
      await _repository.cancelDailyReminder();
    }
  }

  /// Whether the user has turned the reminder on (independent of premium).
  Future<bool> isReminderEnabled() => _repository.isReminderEnabled();

  /// Turns the reminder on: requests permission, persists the preference, and
  /// schedules. Returns whether it ended up enabled (permission may be denied).
  Future<bool> enableReminder() async {
    if (kIsWeb) return false;

    final granted = await _repository.requestPermission();
    if (!granted) {
      await _repository.setReminderEnabled(false);
      await _repository.cancelDailyReminder();
      return false;
    }

    await _repository.setReminderEnabled(true);
    await syncSchedule();
    return true;
  }

  /// Turns the reminder off: persists the preference and cancels the schedule.
  Future<void> disableReminder() async {
    await _repository.setReminderEnabled(false);
    if (kIsWeb) return;
    await _repository.cancelDailyReminder();
  }

  /// Reads the payload of a notification that cold-started the app and routes
  /// after the first frame (so the navigator exists).
  Future<void> _handleLaunchPayload() async {
    final payload = await _repository.launchPayload();
    if (payload == kOnThisDayPayload) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _routeToOnThisDay());
    }
  }

  void _routeToOnThisDay() {
    // The "Neste dia" screen lives inside the timeline (it needs a loaded
    // TimeLineBloc + moments), so we route to the timeline. If the user is not
    // logged in / no timeline selected yet, the normal startup flow takes over.
    navigatorKey.currentState?.pushNamed(AppRoute.timeLine.tag);
  }
}
