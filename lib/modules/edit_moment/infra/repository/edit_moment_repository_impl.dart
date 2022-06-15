import 'package:injectable/injectable.dart';
import 'package:nossos_momentos/modules/add_moment/domain/entities/moment.dart';
import 'package:nossos_momentos/modules/add_moment/infra/models/moment_model.dart';
import 'package:nossos_momentos/modules/edit_moment/domain/repository/edit_moment_repository.dart';
import 'package:nossos_momentos/modules/edit_moment/infra/data_source/update_moment_data_source.dart';

@Injectable(as: EditMomentRepository)
class EditMomentRepositoryImpl extends EditMomentRepository {
  final UpdateMomentDataSource _dataSource;

  EditMomentRepositoryImpl(this._dataSource);

  @override
  Future editMoment(Moment moment) async => await _dataSource.updateMoment(
      moment.id, MomentModel.fromEntity(moment).toMap());
}
