import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:injectable/injectable.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

/// Payload carried by the "Neste dia" notification. The app routes on this when
/// the user taps the notification (see `NotificationTapRouter`).
const String kOnThisDayPayload = 'on_this_day';

/// Notification id reserved for the recurring daily "Neste dia" reminder. A
/// fixed id lets us replace/cancel the schedule deterministically.
const int kOnThisDayNotificationId = 1001;

/// Payload carried by one-shot couple reminders (special dates / time
/// capsules). The tap routes to the timeline, same as "Neste dia".
const String kCoupleReminderPayload = 'couple_reminder';

const String _channelId = 'on_this_day_channel';
const String _channelName = 'Neste dia';
const String _channelDescription =
    'Lembrete diário das memórias do casal neste dia em outros anos.';

/// Called when a notification is tapped while the app is in the background or
/// terminated. Must be a top-level / static function with this annotation.
@pragma('vm:entry-point')
void notificationBackgroundTapHandler(NotificationResponse response) {
  // No-op in the background isolate: the foreground app reads the launch
  // details on startup (`getNotificationAppLaunchDetails`) and routes from
  // there. Kept so Android can register the background callback.
}

/// Talks to the `flutter_local_notifications` SDK and the `timezone` database.
/// This is the ONLY place that imports those plugins. The plugin only supports
/// mobile/desktop, so callers must guard web (`kIsWeb`) before using it.
abstract class LocalNotificationDataSource {
  Future<void> init({void Function(String? payload)? onTap});
  Future<bool> requestPermission();
  Future<void> scheduleDailyReminder({
    required int id,
    required int hour,
    required int minute,
    required String title,
    required String body,
    required String payload,
  });

  /// Schedules a single (non-recurring) zoned notification at [when]. Replacing
  /// an existing [id] reschedules it.
  Future<void> scheduleAt({
    required int id,
    required DateTime when,
    required String title,
    required String body,
    required String payload,
  });

  Future<void> cancel(int id);

  /// Payload of the notification that launched the app, if any (cold start tap).
  Future<String?> launchPayload();
}

@Injectable(as: LocalNotificationDataSource)
class FlutterLocalNotificationDataSource extends LocalNotificationDataSource {
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  @override
  Future<void> init({void Function(String? payload)? onTap}) async {
    if (_initialized) return;

    tz_data.initializeTimeZones();

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      // We request permission explicitly later, so don't prompt at init.
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(
      settings: settings,
      onDidReceiveNotificationResponse: (response) => onTap?.call(response.payload),
      onDidReceiveBackgroundNotificationResponse: notificationBackgroundTapHandler,
    );

    // Create the Android channel up front so scheduled notifications post.
    final androidImpl = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await androidImpl?.createNotificationChannel(
      const AndroidNotificationChannel(
        _channelId,
        _channelName,
        description: _channelDescription,
        importance: Importance.high,
      ),
    );

    _initialized = true;
  }

  @override
  Future<bool> requestPermission() async {
    final androidImpl = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (androidImpl != null) {
      final granted = await androidImpl.requestNotificationsPermission();
      return granted ?? false;
    }

    final iosImpl = _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    if (iosImpl != null) {
      final granted = await iosImpl.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return granted ?? false;
    }

    return false;
  }

  @override
  Future<void> scheduleDailyReminder({
    required int id,
    required int hour,
    required int minute,
    required String title,
    required String body,
    required String payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.high,
      priority: Priority.high,
    );
    const iosDetails = DarwinNotificationDetails();
    const details =
        NotificationDetails(android: androidDetails, iOS: iosDetails);

    await _plugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: _nextInstanceOf(hour, minute),
      notificationDetails: details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      // Repeat every day at the same wall-clock time.
      matchDateTimeComponents: DateTimeComponents.time,
      payload: payload,
    );
  }

  @override
  Future<void> scheduleAt({
    required int id,
    required DateTime when,
    required String title,
    required String body,
    required String payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.high,
      priority: Priority.high,
    );
    const iosDetails = DarwinNotificationDetails();
    const details =
        NotificationDetails(android: androidDetails, iOS: iosDetails);

    await _plugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: tz.TZDateTime.from(when, tz.local),
      notificationDetails: details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      payload: payload,
    );
  }

  @override
  Future<void> cancel(int id) => _plugin.cancel(id: id);

  @override
  Future<String?> launchPayload() async {
    final details = await _plugin.getNotificationAppLaunchDetails();
    if (details?.didNotificationLaunchApp ?? false) {
      return details?.notificationResponse?.payload;
    }
    return null;
  }

  /// Next [hour]:[minute] in the device's local zone (today if still ahead,
  /// otherwise tomorrow).
  tz.TZDateTime _nextInstanceOf(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }
}
