import 'package:injectable/injectable.dart';
import 'package:nossos_momentos/modules/core/use_case/use_case.dart';
import 'package:nossos_momentos/modules/moment/domain/entities/moment.dart';
import 'package:nossos_momentos/modules/time_line/domain/repository/time_line_repository.dart';

@injectable
class GetMomentsUseCase extends AsyncUseCase<List<Moment>, GetMomentsParam> {
  final TimeLineRepository repository;

  const GetMomentsUseCase(this.repository);

  @override
  Future<List<Moment>> execute(GetMomentsParam params) async {
    final response = await repository.getMoments(
      year: params.year.toLowerCase(),
      month: params.month?.toLowerCase() ?? '',
      timeLineId: params.timelineId
    );
    return response;
  }
}

class GetMomentsParam {
  final String year;
  final String? month;
  final String timelineId;

  GetMomentsParam({required this.year, this.month, required this.timelineId});
}
