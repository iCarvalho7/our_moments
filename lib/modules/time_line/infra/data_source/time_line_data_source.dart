import 'package:nossos_momentos/modules/time_line/infra/models/moment_model.dart';

abstract class TimeLineDataSource {

  Future<List<MomentModel>> fetchAllMomentsByMonthAndYear({
    required int year,
    required String month,
  });
}
