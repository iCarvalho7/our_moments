import 'dart:async';

import 'package:injectable/injectable.dart';
import 'package:nossos_momentos/modules/core/use_case/use_case.dart';

import '../../../time_line/domain/repository/time_line_repository.dart';
import '../entities/moment.dart';
import '../repository/moment_repository.dart';

@injectable
class RegisterMomentsUseCase extends AsyncUseCase<void, Moment> {
  final MomentRepository repository;
  final TimeLineRepository _timeLineRepository;

  RegisterMomentsUseCase(this.repository, this._timeLineRepository);

  @override
  Future<void> execute(Moment params) async {
    await _timeLineRepository.updateTimeLineMomentIds(params);
    return repository.registerMoment(moment: params);
  }
}
