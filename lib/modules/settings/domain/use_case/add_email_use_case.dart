import 'package:injectable/injectable.dart';
import 'package:nossos_momentos/modules/core/use_case/use_case.dart';
import 'package:nossos_momentos/modules/settings/domain/use_case/delete_email_use_case.dart';
import 'package:nossos_momentos/modules/time_line/domain/entity/time_line.dart';
import 'package:nossos_momentos/modules/time_line/domain/repository/time_line_repository.dart';

@injectable
class AddEmailUseCase extends AsyncUseCase<TimeLine, EmailParam> {
  final TimeLineRepository repository;

  AddEmailUseCase(this.repository);

  @override
  Future<TimeLine> execute(EmailParam params) {
    return repository.updateTimeLineEmails(params.timeline, params.email);
  }
}
