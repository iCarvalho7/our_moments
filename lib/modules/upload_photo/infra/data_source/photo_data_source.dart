import 'dart:async';
import 'dart:io';

abstract class PhotoDataSource {
  FutureOr<List<String>> uploadPhotoFromPath(List<File> paths, String momentId);

  Future deletePhotos(String momentId);
}