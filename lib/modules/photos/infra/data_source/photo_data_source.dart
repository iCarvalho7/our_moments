import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

abstract class PhotoDataSource {
  FutureOr<List<String>> uploadPhotoFromPath(List<File> paths, String momentId);

  /// Uploads raw bytes (used on web, where there is no file system — e.g. an
  /// audio note recorded into a blob). Returns the download URL.
  Future<String> uploadAudioFromBytes(Uint8List bytes, String momentId, String fileName);

  /// Uploads a photo/video from raw bytes (used on web, where picked files have
  /// no file-system path and travel as data URLs). Returns the download URL.
  Future<String> uploadPhotoFromBytes(Uint8List bytes, String momentId, String fileName);

  Future clearAllMomentPhotos(String momentId);

  Future deleteMomentPhoto(List<String> paths, String momentId);

  /// Downloads raw bytes from any HTTP/blob URL. Returns null on failure.
  Future<({Uint8List bytes, String? contentType})?> fetchBytes(String url);
}