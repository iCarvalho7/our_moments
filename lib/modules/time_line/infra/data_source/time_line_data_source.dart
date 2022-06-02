import 'package:nossos_momentos/modules/time_line/infra/models/time_line_moment_model.dart';

abstract class TimeLineDataSource {

  Future<List<TimeLineMomentModel>> fetchAllMomentsByMonthAndYear({
    required int year,
    required String month,
  });
}
