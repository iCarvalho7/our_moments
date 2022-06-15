import 'dart:async';

import 'package:injectable/injectable.dart';
import 'package:nossos_momentos/modules/add_moment/domain/entities/moment.dart';
import 'package:nossos_momentos/modules/add_moment/domain/repository/get_moment_repository.dart';
import 'package:nossos_momentos/modules/add_moment/infra/data_source/moments_data_source.dart';

@Injectable(as: GetMomentRepository)
class GetMomentRepositoryImpl extends GetMomentRepository {
  final MomentsDataSource momentsDataSource;

  GetMomentRepositoryImpl(this.momentsDataSource);

  @override
  FutureOr<Moment> fetchMomentById(String id) async {
    final momentModel = await momentsDataSource.fetchMoment(momentId: id);
    return momentModel.toEntity();
  }
}
