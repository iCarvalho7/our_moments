import 'package:injectable/injectable.dart';
import 'package:nossos_momentos/modules/time_line/domain/entity/time_line_moment.dart';
import 'package:nossos_momentos/modules/time_line/domain/repository/time_line_repository.dart';
import 'package:nossos_momentos/modules/time_line/infra/data_source/time_line_data_source.dart';

@Injectable(as: TimeLineRepository)
class TimeLineRepositoryImpl extends TimeLineRepository {
  final TimeLineDataSource dataSource;

  TimeLineRepositoryImpl({
    required this.dataSource,
  });

  @override
  Future<List<TimeLineMoment>> getMoments({required int year, required String month}) async {
    final result = await dataSource.fetchAllMomentsByMonthAndYear(year: year, month: month);
    return result.map((e) => e.toEntity()).toList();
  }
}
