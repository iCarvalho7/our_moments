import 'package:injectable/injectable.dart';
import 'package:nossos_momentos/modules/core/use_case/use_case.dart';
import 'package:nossos_momentos/modules/notifications/notification_service.dart';

import '../repository/time_capsule_repository.dart';

class RemoveTimeCapsuleParams {
  final String timelineId;
  final String id;

  const RemoveTimeCapsuleParams({required this.timelineId, required this.id});
}

@injectable
class RemoveTimeCapsuleUseCase
    extends AsyncUseCase<void, RemoveTimeCapsuleParams> {
  final TimeCapsuleRepository _repository;
  final NotificationService _notificationService;

  RemoveTimeCapsuleUseCase(this._repository, this._notificationService);

  @override
  Future<void> execute(RemoveTimeCapsuleParams params) async {
    await _repository.remove(params.timelineId, params.id);
    await _notificationService
        .cancel(NotificationService.notificationIdFor(params.id));
  }
}
