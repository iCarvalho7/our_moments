import 'package:injectable/injectable.dart';
import 'package:nossos_momentos/modules/add_moment/domain/entities/moment.dart';
import 'package:nossos_momentos/modules/add_moment/domain/repository/register_moment_repository.dart';
import 'package:nossos_momentos/modules/add_moment/infra/data_source/moments_data_source.dart';
import 'package:nossos_momentos/modules/add_moment/infra/models/moment_model.dart';

@Injectable(as: RegisterMomentRepository)
class RegisterMomentRepositoryImpl extends RegisterMomentRepository {
  final MomentsDataSource dataSource;

  RegisterMomentRepositoryImpl(this.dataSource);

  @override
  Future registerMoment({required Moment moment}) =>
    dataSource.registerMoment(moment: MomentModel.fromEntity(moment));

}
