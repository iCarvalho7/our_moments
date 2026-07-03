import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _kReminderEnabledKey = 'on_this_day_reminder_enabled';

/// Persists the user's "Neste dia" reminder on/off preference locally.
abstract class NotificationPreferenceStore {
  Future<bool> isReminderEnabled();
  Future<void> setReminderEnabled(bool enabled);
}

@Injectable(as: NotificationPreferenceStore)
class SharedPrefsNotificationPreferenceStore
    extends NotificationPreferenceStore {
  @override
  Future<bool> isReminderEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_kReminderEnabledKey) ?? false;
  }

  @override
  Future<void> setReminderEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kReminderEnabledKey, enabled);
  }
}
