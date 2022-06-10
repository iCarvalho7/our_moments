import 'dart:async';
import 'dart:io';

import 'package:injectable/injectable.dart';
import 'package:nossos_momentos/modules/upload_photo/domain/repository/upload_photo_repository.dart';
import 'package:nossos_momentos/modules/upload_photo/infra/data_source/photo_data_source.dart';

@Injectable(as: UploadPhotoRepository)
class UploadPhotoRepositoryImpl extends UploadPhotoRepository {
  final PhotoDataSource dataSource;

  UploadPhotoRepositoryImpl(this.dataSource);

  @override
  FutureOr<List<String>> uploadPhotoToFirebaseStorage(
    List<File> paths,
    String momentId,
  ) => dataSource.uploadPhotoFromPath(paths, momentId);
}
