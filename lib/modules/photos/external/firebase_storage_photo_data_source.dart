import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:injectable/injectable.dart';
import 'package:nossos_momentos/modules/core/utils/logging/request_logger.dart';
import 'package:nossos_momentos/modules/photos/infra/data_source/photo_data_source.dart';

@Injectable(as: PhotoDataSource)
class FirebaseStoragePhotoDataSource extends PhotoDataSource {
  final Reference momentsPhotoRef;

  FirebaseStoragePhotoDataSource(
    @Named(photosStorage) this.momentsPhotoRef,
  );

  @override
  FutureOr<List<String>> uploadPhotoFromPath(
    List<File> paths,
    String momentId,
  ) =>
      RequestLogger.track(
        'Storage.uploadPhotoFromPath',
        params: {'momentId': momentId, 'files': paths.length},
        request: () => Future.wait(paths.map((file) => _uploadFile(file, momentId))),
      );

  @override
  Future<String> uploadAudioFromBytes(Uint8List bytes, String momentId, String fileName) => RequestLogger.track(
        'Storage.uploadAudioFromBytes',
        params: {'momentId': momentId, 'fileName': fileName, 'bytes': bytes.length},
        request: () async {
          final ref = momentsPhotoRef.child('$momentId/$fileName');
          final task = await ref.putData(
            bytes,
            SettableMetadata(contentType: _audioContentType(fileName)),
          );
          return task.ref.getDownloadURL();
        },
      );

  @override
  Future<String> uploadPhotoFromBytes(Uint8List bytes, String momentId, String fileName) =>
      RequestLogger.track(
        'Storage.uploadPhotoFromBytes',
        params: {'momentId': momentId, 'fileName': fileName, 'bytes': bytes.length},
        request: () async {
          final ref = momentsPhotoRef.child('$momentId/$fileName');
          final task = await ref.putData(
            bytes,
            SettableMetadata(contentType: _imageContentType(fileName)),
          );
          return task.ref.getDownloadURL();
        },
      );

  String _imageContentType(String fileName) {
    final name = fileName.toLowerCase();
    if (name.endsWith('.png')) return 'image/png';
    if (name.endsWith('.gif')) return 'image/gif';
    if (name.endsWith('.webp')) return 'image/webp';
    if (name.endsWith('.heic')) return 'image/heic';
    if (name.endsWith('.bmp')) return 'image/bmp';
    if (name.endsWith('.mp4')) return 'video/mp4';
    if (name.endsWith('.mov')) return 'video/quicktime';
    if (name.endsWith('.webm')) return 'video/webm';
    return 'image/jpeg';
  }

  String _audioContentType(String fileName) {
    if (fileName.endsWith('.webm')) return 'audio/webm';
    if (fileName.endsWith('.m4a') || fileName.endsWith('.mp4')) return 'audio/mp4';
    if (fileName.endsWith('.ogg')) return 'audio/ogg';
    return 'application/octet-stream';
  }

  Future<String> _uploadFile(File image, String id) async {
    final child = "$id/${image.path.split('/').last.replaceAll(' ', '_')}";
    final uploadTask = momentsPhotoRef.child(child).putFile(image);
    String downloadUrl = '';

    await uploadTask.then((TaskSnapshot task) async {
      downloadUrl = await task.ref.getDownloadURL();
    });

    return downloadUrl;
  }

  @override
  Future clearAllMomentPhotos(String momentId) => RequestLogger.track(
        'Storage.clearAllMomentPhotos',
        params: {'momentId': momentId},
        request: () async {
          final photoItems = (await momentsPhotoRef.child(momentId).listAll()).items;
          for (var element in photoItems) {
            await momentsPhotoRef.child(momentId).child(element.name).delete();
          }
        },
      );

  @override
  Future deleteMomentPhoto(List<String> paths, String momentId) => RequestLogger.track(
        'Storage.deleteMomentPhoto',
        params: {'momentId': momentId, 'paths': paths.length},
        request: () async {
          final photoItems = (await momentsPhotoRef.child(momentId).listAll()).items;
          for (final item in photoItems) {
            final url = await item.getDownloadURL();
            if (paths.contains(url)) {
              await momentsPhotoRef.child(momentId).child(item.name).delete();
            }
          }
        },
      );

  static const String photosStorage = "photosStorage";
}
