import 'package:injectable/injectable.dart';
import 'package:nossos_momentos/modules/core/use_case/use_case.dart';
import 'package:nossos_momentos/modules/login/domain/repository/auth_repository.dart';
import 'package:nossos_momentos/modules/notifications/notification_service.dart';

import '../entity/time_capsule.dart';
import '../repository/time_capsule_repository.dart';

class AddTimeCapsuleParams {
  final String timelineId;
  final String message;
  final DateTime revealDate;
  final String mediaUrl;

  /// All member emails of the timeline (used to pick the recipient).
  final List<String> emails;

  const AddTimeCapsuleParams({
    required this.timelineId,
    required this.message,
    required this.revealDate,
    required this.emails,
    this.mediaUrl = '',
  });
}

@injectable
class AddTimeCapsuleUseCase extends AsyncUseCase<void, AddTimeCapsuleParams> {
  final TimeCapsuleRepository _repository;
  final AuthRepository _authRepository;
  final NotificationService _notificationService;

  AddTimeCapsuleUseCase(
    this._repository,
    this._authRepository,
    this._notificationService,
  );

  @override
  Future<void> execute(AddTimeCapsuleParams params) async {
    final message = params.message.trim();
    if (message.isEmpty) {
      throw Exception('Time capsule message cannot be empty.');
    }

    final fromEmail = _authRepository.getCurrentUser()?.email ?? '';
    // The recipient is the other member of the timeline; fall back to self if
    // there is no partner yet.
    final toEmail = params.emails.firstWhere(
      (e) => e != fromEmail,
      orElse: () => fromEmail,
    );

    final docId = await _repository.add(
      params.timelineId,
      TimeCapsule(
        // Firestore generates the id; an empty placeholder is fine here.
        id: '',
        message: message,
        mediaUrl: params.mediaUrl,
        revealDate: params.revealDate,
        fromEmail: fromEmail,
        toEmail: toEmail,
      ),
    );

    // Schedule the reveal notification. Past dates are skipped by the service.
    await _notificationService.scheduleSpecialDate(
      notificationId: NotificationService.notificationIdFor(docId),
      title: 'Cápsula do tempo 💌',
      body: 'Uma cápsula do tempo foi revelada. Toque para abrir.',
      when: params.revealDate,
    );
  }
}
