import 'package:injectable/injectable.dart';
import 'package:nossos_momentos/modules/moment/domain/entities/moment.dart';
import 'package:nossos_momentos/modules/moment/infra/data_source/moments_data_source.dart';
import 'package:nossos_momentos/modules/time_line/domain/repository/time_line_repository.dart';

@Injectable(as: TimeLineRepository)
class TimeLineRepositoryImpl extends TimeLineRepository {
  final MomentsDataSource dataSource;

  TimeLineRepositoryImpl({
    required this.dataSource,
  });

  @override
  Future<List<Moment>> getMoments({
    required String year,
    required String month,
  }) async {
    if (month.isNotEmpty) {
      final result = await dataSource.fetchAllMomentsByMonthAndYear(
        year: year,
        month: month,
      );
      return result.map((e) => e.toEntity()).toList();
    } else {
      final result = await dataSource.fetchAllMomentsByYear(
        year: year.toString(),
      );
      return result.map((e) => e.toEntity()).toList()..sort((a, b) => a.dateTime.compareTo(b.dateTime));
    }
  }
}
