import 'dart:async';
import 'dart:io';

abstract class PhotoDataSource {
  FutureOr<List<String>> uploadPhotoFromPath(List<File> paths, String momentId);

  Future clearAllMomentPhotos(String momentId);

  Future deleteMomentPhoto(List<String> paths, String momentId);
}