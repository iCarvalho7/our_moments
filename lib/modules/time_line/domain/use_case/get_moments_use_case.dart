import 'package:injectable/injectable.dart';
import 'package:nossos_momentos/modules/time_line/domain/entity/time_line_moment.dart';
import 'package:nossos_momentos/modules/time_line/domain/repository/time_line_repository.dart';

mixin GetMomentsUseCase {
  Future<List<TimeLineMoment>> call({
    required String year,
    String month,
  });
}

@Injectable(as: GetMomentsUseCase)
class GetMomentsUseCaseImpl implements GetMomentsUseCase {
  final TimeLineRepository repository;
  late List<TimeLineMoment> moments;

  GetMomentsUseCaseImpl(this.repository);

  @override
  Future<List<TimeLineMoment>> call({
    required String year,
    String month = '',
  }) async {
    final response = await repository.getMoments(
      year: year.toLowerCase(),
      month: month.toLowerCase(),
    );
    moments = response;
    return response;
  }
}
