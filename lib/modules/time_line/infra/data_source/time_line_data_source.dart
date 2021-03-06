import 'package:nossos_momentos/modules/time_line/infra/models/time_line_moment_model.dart';

abstract class TimeLineDataSource {

  Future<List<TimeLineMomentModel>> fetchAllMomentsByMonthAndYear({
    required String year,
    required String month,
  });

  Future<List<TimeLineMomentModel>> fetchAllMomentsByYear({
    required String year,
  });
}
