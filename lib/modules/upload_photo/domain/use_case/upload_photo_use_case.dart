import 'dart:async';
import 'dart:io';

import 'package:injectable/injectable.dart';
import 'package:nossos_momentos/modules/upload_photo/domain/repository/photos_repository.dart';

@injectable
class UploadPhotoUseCase {
  final PhotosRepository repository;

  UploadPhotoUseCase(this.repository);

  FutureOr<List<String>> call(List<String> path, String momentId) async {
    final pathList = path.map((e) => File(e)).toList();
    return await repository.uploadPhotoToFirebaseStorage(pathList, momentId);
  }
}