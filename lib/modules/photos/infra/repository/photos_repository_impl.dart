import 'dart:async';
import 'dart:io';

import 'package:injectable/injectable.dart';
import 'package:nossos_momentos/modules/photos/domain/repository/photos_repository.dart';
import 'package:nossos_momentos/modules/photos/infra/data_source/photo_data_source.dart';

@Injectable(as: PhotosRepository)
class PhotosRepositoryImpl extends PhotosRepository {
  final PhotoDataSource dataSource;

  PhotosRepositoryImpl(this.dataSource);

  @override
  FutureOr<List<String>> uploadPhotoToFirebaseStorage(
    List<File> paths,
    String momentId,
  ) => dataSource.uploadPhotoFromPath(paths, momentId);

  @override
  Future clearAllPhotosFromMoment(String momentId) => dataSource.clearAllMomentPhotos(momentId);

  @override
  Future deletePhotosFromMoment(List<String> paths, String momentId) => dataSource.deleteMomentPhoto(paths, momentId);
}
