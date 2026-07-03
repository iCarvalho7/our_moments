/// Boundary over the local-notifications mechanism.
///
/// The infra layer talks to the `flutter_local_notifications` SDK; everything
/// above stays SDK-agnostic. Used by the "Neste dia" daily reminder feature.
abstract class NotificationRepository {
  /// Initializes the underlying plugin (channels, timezone database, tap
  /// handler). [onTap] fires with the notification payload when the user taps a
  /// notification while the app is running. Safe to call once at app startup.
  Future<void> init({void Function(String? payload)? onTap});

  /// Payload of the notification that cold-started the app, if any.
  Future<String?> launchPayload();

  /// Requests the OS notification permission (iOS / Android 13+). Returns
  /// whether permission is granted.
  Future<bool> requestPermission();

  /// Schedules a recurring daily reminder at [hour]:[minute] (local time) with
  /// the given [title]/[body]. Re-scheduling replaces any previous schedule.
  Future<void> scheduleDailyReminder({
    required int hour,
    required int minute,
    required String title,
    required String body,
  });

  /// Cancels the daily reminder, if scheduled.
  Future<void> cancelDailyReminder();

  /// Schedules a single (non-recurring) reminder identified by [id] at [when]
  /// (local time). Re-using an [id] reschedules it.
  Future<void> scheduleReminderAt({
    required int id,
    required DateTime when,
    required String title,
    required String body,
  });

  /// Cancels a previously scheduled reminder by [id].
  Future<void> cancelReminder(int id);

  /// Reads the persisted user preference (whether the reminder is enabled).
  Future<bool> isReminderEnabled();

  /// Persists the user preference (whether the reminder is enabled).
  Future<void> setReminderEnabled(bool enabled);
}
