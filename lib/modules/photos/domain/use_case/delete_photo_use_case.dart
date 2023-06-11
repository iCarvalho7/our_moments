import 'package:injectable/injectable.dart';
import 'package:nossos_momentos/modules/core/use_case/use_case.dart';
import 'package:nossos_momentos/modules/photos/domain/use_case/upload_photo_use_case.dart';

import '../repository/photos_repository.dart';

@injectable
class DeletePhotoUseCase extends AsyncUseCase<void, PhotoParams>{

  final PhotosRepository _photosRepository;

  DeletePhotoUseCase(this._photosRepository);

  @override
  Future<void> execute(PhotoParams params) => _photosRepository.deletePhotosFromMoment(params.paths, params.momentId);

}