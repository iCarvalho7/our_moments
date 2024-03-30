import 'dart:async';

import 'package:injectable/injectable.dart';
import '../../domain/entities/moment.dart';
import '../../domain/repository/moment_repository.dart';
import '../data_source/moments_data_source.dart';
import '../models/moment_model.dart';

@Injectable(as: MomentRepository)
class MomentRepositoryImpl extends MomentRepository {
  final MomentsDataSource _dataSource;

  MomentRepositoryImpl(this._dataSource);

  @override
  Future registerMoment({required Moment moment}) {
    return _dataSource.registerMoment(
      moment: MomentModel.fromEntity(moment),
    );
  }

  @override
  FutureOr<Moment> fetchMomentById(String id) async {
    final momentModel = await _dataSource.fetchMoment(momentId: id);
    return momentModel.toEntity();
  }

  @override
  Future editMoment(Moment moment) => _dataSource.updateMoment(
        moment.id,
        MomentModel.fromEntity(moment).toJson(),
      );

  @override
  Future deleteMoment(String momentId) => _dataSource.deleteMoment(momentId);
}
