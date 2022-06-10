import 'dart:async';
import 'dart:io';

abstract class UploadPhotoRepository {
  FutureOr<List<String>> uploadPhotoToFirebaseStorage(List<File> paths, String momentId);
}