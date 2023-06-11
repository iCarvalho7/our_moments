import 'dart:async';
import 'dart:io';

import 'package:injectable/injectable.dart';
import 'package:nossos_momentos/modules/core/use_case/use_case.dart';
import 'package:nossos_momentos/modules/photos/domain/repository/photos_repository.dart';

@injectable
class UploadPhotoUseCase extends AsyncUseCase<List<String>, PhotoParams> {
  final PhotosRepository repository;

  UploadPhotoUseCase(this.repository);

  @override
  Future<List<String>> execute(PhotoParams params) async {
    final pathList = params.paths.map((e) => File(e)).toList();
    return await repository.uploadPhotoToFirebaseStorage(pathList, params.momentId);
  }
}

class PhotoParams {
  final List<String> paths;
  final String momentId;

  PhotoParams({required this.paths, required this.momentId});
}
