import 'package:injectable/injectable.dart';

import '../../domain/entity/special_date.dart';
import '../../domain/repository/special_dates_repository.dart';
import '../data_source/special_dates_data_source.dart';
import '../model/special_date_model.dart';

@Injectable(as: SpecialDatesRepository)
class SpecialDatesRepositoryImpl extends SpecialDatesRepository {
  final SpecialDatesDataSource _dataSource;

  SpecialDatesRepositoryImpl(this._dataSource);

  @override
  Stream<List<SpecialDate>> watch(String timelineId) {
    return _dataSource
        .watch(timelineId)
        .map((items) => items.map((e) => e.toEntity()).toList());
  }

  @override
  Future<String> add(String timelineId, SpecialDate date) {
    return _dataSource.add(
      timelineId,
      SpecialDateModel(
        id: date.id,
        title: date.title,
        date: date.date,
        remindDaysBefore: date.remindDaysBefore,
        createdBy: date.createdBy,
      ),
    );
  }

  @override
  Future<void> remove(String timelineId, String id) {
    return _dataSource.remove(timelineId, id);
  }
}
