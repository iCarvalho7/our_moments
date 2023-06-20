import 'dart:async';
import 'dart:io';

import 'package:injectable/injectable.dart';
import 'package:nossos_momentos/modules/photos/domain/repository/photos_repository.dart';
import 'package:nossos_momentos/modules/photos/infra/data_source/photo_data_source.dart';
import 'package:nossos_momentos/modules/stories/domain/entity/story.dart';

import '../../external/file_picker_data_source.dart';

@Injectable(as: PhotosRepository)
class PhotosRepositoryImpl extends PhotosRepository {
  final PhotoDataSource dataSource;
  final FilePickerDataSource filePickerDataSource;

  PhotosRepositoryImpl(this.dataSource, this.filePickerDataSource);

  @override
  FutureOr<List<String>> uploadPhotoToFirebaseStorage(
    List<File> paths,
    String momentId,
  ) => dataSource.uploadPhotoFromPath(paths, momentId);

  @override
  Future clearAllPhotosFromMoment(String momentId) => dataSource.clearAllMomentPhotos(momentId);

  @override
  Future deletePhotosFromMoment(
    List<String> paths,
    String momentId,
  ) => dataSource.deleteMomentPhoto(paths, momentId);

  @override
  Future<List<Story>> getMedia() async {
    final files = await filePickerDataSource.getFiles();
    return files?.whereType<String>().map((e) => Story(url: e)).toList() ?? [];
  }
}
