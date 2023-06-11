import 'package:injectable/injectable.dart';
import 'package:nossos_momentos/modules/core/use_case/use_case.dart';

import '../repository/photos_repository.dart';

@injectable
class DeletePhotoUseCase extends AsyncUseCase<void, String> {
  final PhotosRepository _photosRepository;

  DeletePhotoUseCase(this._photosRepository);

  @override
  Future<void> execute(String params) => _photosRepository.deletePhotos(params);
}
