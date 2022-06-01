import 'package:injectable/injectable.dart';
import 'package:nossos_momentos/modules/time_line/domain/entities/moment.dart';
import 'package:nossos_momentos/modules/time_line/domain/repository/time_line_repository.dart';

mixin GetMomentsUseCase {
  Future<List<Moment>> call({
    required int year,
    required String month,
  });
}

@Injectable(as: GetMomentsUseCase)
class GetMomentsUseCaseImpl implements GetMomentsUseCase {
  final TimeLineRepository repository;
  late List<Moment> moments;

  GetMomentsUseCaseImpl(this.repository);

  @override
  Future<List<Moment>> call({
    required int year,
    required String month,
  }) async {
    final response = await repository.getMoments(year: year, month: month);
    moments = response;
    return response;

  }
}
