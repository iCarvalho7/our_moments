import 'package:injectable/injectable.dart';

import '../../domain/repository/notification_repository.dart';
import '../data_source/local_notification_data_source.dart';
import '../data_source/notification_preference_store.dart';

@Injectable(as: NotificationRepository)
class NotificationRepositoryImpl extends NotificationRepository {
  final LocalNotificationDataSource _local;
  final NotificationPreferenceStore _store;

  NotificationRepositoryImpl(this._local, this._store);

  @override
  Future<void> init({void Function(String? payload)? onTap}) =>
      _local.init(onTap: onTap);

  @override
  Future<String?> launchPayload() => _local.launchPayload();

  @override
  Future<bool> requestPermission() => _local.requestPermission();

  @override
  Future<void> scheduleDailyReminder({
    required int hour,
    required int minute,
    required String title,
    required String body,
  }) =>
      _local.scheduleDailyReminder(
        id: kOnThisDayNotificationId,
        hour: hour,
        minute: minute,
        title: title,
        body: body,
        payload: kOnThisDayPayload,
      );

  @override
  Future<void> cancelDailyReminder() => _local.cancel(kOnThisDayNotificationId);

  @override
  Future<void> scheduleReminderAt({
    required int id,
    required DateTime when,
    required String title,
    required String body,
  }) =>
      _local.scheduleAt(
        id: id,
        when: when,
        title: title,
        body: body,
        payload: kCoupleReminderPayload,
      );

  @override
  Future<void> cancelReminder(int id) => _local.cancel(id);

  @override
  Future<bool> isReminderEnabled() => _store.isReminderEnabled();

  @override
  Future<void> setReminderEnabled(bool enabled) =>
      _store.setReminderEnabled(enabled);
}
