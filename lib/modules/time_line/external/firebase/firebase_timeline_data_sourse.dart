import 'package:injectable/injectable.dart';
import 'package:nossos_momentos/modules/time_line/infra/data_source/time_line_data_source.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nossos_momentos/modules/time_line/infra/models/time_line_moment_model.dart';

@Injectable(as: TimeLineDataSource)
class FirebaseTimeLineDataSource extends TimeLineDataSource {
  final CollectionReference<TimeLineMomentModel> momentsDBRef;

  FirebaseTimeLineDataSource(
    @Named(momentsDBParam) this.momentsDBRef,
  );

  @override
  Future<List<TimeLineMomentModel>> fetchAllMomentsByMonthAndYear({
    required int year,
    required String month,
  }) async {
    final result = await momentsDBRef
        .where(yearQuery, isEqualTo: year.toString())
        .where(monthQuery, isEqualTo: month)
        .get(const GetOptions(source: Source.server));
    return result.docs.map((e) => e.data()).toList();
  }

  static const momentsDBParam = 'momentsDBRef';
  static const yearQuery = 'year';
  static const monthQuery = 'month';
  static const titleParam = 'title';
  static const bodyParam = 'body';
}
