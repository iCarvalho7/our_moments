import 'package:injectable/injectable.dart';
import 'package:nossos_momentos/modules/moment/domain/entities/moment.dart';
import 'package:nossos_momentos/modules/time_line/domain/repository/time_line_repository.dart';

mixin GetMomentsUseCase {
  Future<List<Moment>> call({
    required String year,
    String? month,
  });
}

@Injectable(as: GetMomentsUseCase)
class GetMomentsUseCaseImpl implements GetMomentsUseCase {
  final TimeLineRepository repository;

  const GetMomentsUseCaseImpl(this.repository);

  @override
  Future<List<Moment>> call({
    required String year,
    String? month = '',
  }) async {
    final response = await repository.getMoments(
      year: year.toLowerCase(),
      month: month?.toLowerCase() ?? '',
    );
    return response;
  }
}
