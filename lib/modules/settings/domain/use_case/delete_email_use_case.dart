import 'package:injectable/injectable.dart';
import 'package:nossos_momentos/modules/core/use_case/use_case.dart';
import 'package:nossos_momentos/modules/time_line/domain/entity/time_line.dart';
import 'package:nossos_momentos/modules/time_line/domain/repository/time_line_repository.dart';

@injectable
class DeleteEmailUseCase extends AsyncUseCase<TimeLine, EmailParam> {
  final TimeLineRepository repository;

  DeleteEmailUseCase(this.repository);

  @override
  Future<TimeLine> execute(EmailParam params) async{
    return repository.removeTimeLineMember(params.timeline, params.email);
  }
}

class EmailParam {
  final String email;
  final TimeLine timeline;

  EmailParam({required this.email, required this.timeline});
}
