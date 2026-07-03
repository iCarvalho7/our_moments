import 'package:injectable/injectable.dart';
import 'package:nossos_momentos/modules/core/use_case/use_case.dart';
import 'package:nossos_momentos/modules/notifications/notification_service.dart';

import '../repository/special_dates_repository.dart';

class RemoveSpecialDateParams {
  final String timelineId;
  final String id;

  const RemoveSpecialDateParams({required this.timelineId, required this.id});
}

@injectable
class RemoveSpecialDateUseCase
    extends AsyncUseCase<void, RemoveSpecialDateParams> {
  final SpecialDatesRepository _repository;
  final NotificationService _notificationService;

  RemoveSpecialDateUseCase(this._repository, this._notificationService);

  @override
  Future<void> execute(RemoveSpecialDateParams params) async {
    await _repository.remove(params.timelineId, params.id);
    await _notificationService
        .cancel(NotificationService.notificationIdFor(params.id));
  }
}
