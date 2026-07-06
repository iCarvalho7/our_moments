import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import '../../../stories/domain/entity/story.dart';

abstract class PhotosRepository {
  FutureOr<List<String>> uploadPhotoToFirebaseStorage(List<File> paths, String momentId);

  /// Uploads audio bytes to storage (web has no file system). Returns the URL.
  Future<String> uploadAudioBytes(Uint8List bytes, String momentId, String fileName);

  /// Uploads photo/video bytes to storage (web has no file system). Returns the URL.
  Future<String> uploadPhotoBytes(Uint8List bytes, String momentId, String fileName);

  Future clearAllPhotosFromMoment(String momentId);

  Future deletePhotosFromMoment(List<String> paths, String momentId);

  Future<List<Story>> getMedia();

  /// Downloads raw bytes from any HTTP/blob URL. Returns null on failure.
  Future<({Uint8List bytes, String? contentType})?> fetchBytes(String url);
}