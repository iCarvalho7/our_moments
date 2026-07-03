import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

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

  /// Uploads an audio note from raw bytes (used on web, where recordings live
  /// in a blob instead of the file system). Returns the download URL.
  Future<String> uploadAudioBytes(Uint8List bytes, String momentId, String fileName) =>
      repository.uploadAudioBytes(bytes, momentId, fileName);

  /// Uploads a photo/video from raw bytes (used on web, where picked files have
  /// no file-system path and travel as data URLs). Returns the download URL.
  Future<String> uploadPhotoBytes(Uint8List bytes, String momentId, String fileName) =>
      repository.uploadPhotoBytes(bytes, momentId, fileName);
}

class PhotoParams {
  final List<String> paths;
  final String momentId;

  PhotoParams({required this.paths, required this.momentId});
}
