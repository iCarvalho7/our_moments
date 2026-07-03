import 'package:injectable/injectable.dart';

import '../../domain/entity/time_capsule.dart';
import '../../domain/repository/time_capsule_repository.dart';
import '../data_source/time_capsule_data_source.dart';
import '../model/time_capsule_model.dart';

@Injectable(as: TimeCapsuleRepository)
class TimeCapsuleRepositoryImpl extends TimeCapsuleRepository {
  final TimeCapsuleDataSource _dataSource;

  TimeCapsuleRepositoryImpl(this._dataSource);

  @override
  Stream<List<TimeCapsule>> watch(String timelineId) {
    return _dataSource
        .watch(timelineId)
        .map((items) => items.map((e) => e.toEntity()).toList());
  }

  @override
  Future<String> add(String timelineId, TimeCapsule capsule) {
    return _dataSource.add(
      timelineId,
      TimeCapsuleModel(
        id: capsule.id,
        message: capsule.message,
        mediaUrl: capsule.mediaUrl,
        revealDate: capsule.revealDate,
        fromEmail: capsule.fromEmail,
        toEmail: capsule.toEmail,
        revealed: capsule.revealed,
      ),
    );
  }

  @override
  Future<void> remove(String timelineId, String id) {
    return _dataSource.remove(timelineId, id);
  }
}
