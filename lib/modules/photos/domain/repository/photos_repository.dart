import 'dart:async';
import 'dart:io';

abstract class PhotosRepository {
  FutureOr<List<String>> uploadPhotoToFirebaseStorage(List<File> paths, String momentId);

  Future clearAllPhotosFromMoment(String momentId);

  Future deletePhotosFromMoment(List<String> paths, String momentId);
}