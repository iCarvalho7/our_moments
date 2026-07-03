import 'package:injectable/injectable.dart';

import 'package:nossos_momentos/modules/core/use_case/use_case.dart';
import 'package:nossos_momentos/modules/login/domain/repository/auth_repository.dart';
import 'package:nossos_momentos/modules/notifications/notification_service.dart';

import '../entity/special_date.dart';
import '../repository/special_dates_repository.dart';

class AddSpecialDateParams {
  final String timelineId;
  final String title;
  final DateTime date;
  final int remindDaysBefore;

  const AddSpecialDateParams({
    required this.timelineId,
    required this.title,
    required this.date,
    required this.remindDaysBefore,
  });
}

@injectable
class AddSpecialDateUseCase extends AsyncUseCase<void, AddSpecialDateParams> {
  final SpecialDatesRepository _repository;
  final AuthRepository _authRepository;
  final NotificationService _notificationService;

  AddSpecialDateUseCase(
    this._repository,
    this._authRepository,
    this._notificationService,
  );

  @override
  Future<void> execute(AddSpecialDateParams params) async {
    final title = params.title.trim();
    if (title.isEmpty) {
      throw Exception('Special date title cannot be empty.');
    }

    final remindDaysBefore =
        params.remindDaysBefore < 0 ? 0 : params.remindDaysBefore;

    final docId = await _repository.add(
      params.timelineId,
      SpecialDate(
        // Firestore generates the id; an empty placeholder is fine here.
        id: '',
        title: title,
        date: params.date,
        remindDaysBefore: remindDaysBefore,
        createdBy: _authRepository.getCurrentUser()?.email ?? '',
      ),
    );

    // Schedule the reminder for the next (yearly) occurrence minus the lead
    // days. Past dates are silently skipped by the service.
    final occurrence = NotificationService.nextYearlyOccurrence(params.date);
    final when = occurrence.subtract(Duration(days: remindDaysBefore));
    await _notificationService.scheduleSpecialDate(
      notificationId: NotificationService.notificationIdFor(docId),
      title: 'Data especial 💜',
      body: _reminderBody(title, remindDaysBefore),
      when: when,
    );
  }

  String _reminderBody(String title, int daysBefore) {
    if (daysBefore <= 0) return 'Hoje é "$title". Aproveitem o dia!';
    if (daysBefore == 1) return 'Amanhã é "$title". Preparem algo especial!';
    return 'Faltam $daysBefore dias para "$title".';
  }
}
