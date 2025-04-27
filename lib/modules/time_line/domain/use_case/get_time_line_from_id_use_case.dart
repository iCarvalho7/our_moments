import 'package:injectable/injectable.dart';
import 'package:nossos_momentos/modules/core/use_case/use_case.dart';
import 'package:nossos_momentos/modules/time_line/domain/entity/time_line.dart';
import 'package:nossos_momentos/modules/time_line/domain/repository/time_line_repository.dart';

@injectable
class GetTimeLineFromIdUseCase extends AsyncUseCase<TimeLine, String> {
  final TimeLineRepository repository;

  GetTimeLineFromIdUseCase(this.repository);

  @override
  Future<TimeLine> execute(String params) {
    return repository.getTimeLineById(params);
  }
}
