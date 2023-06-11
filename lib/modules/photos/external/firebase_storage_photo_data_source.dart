import 'dart:async';
import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:injectable/injectable.dart';
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
  ) async {
    final imageUrls = await Future.wait(paths.map((file) => _uploadFile(file, momentId)));
    return imageUrls;
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
  Future clearAllMomentPhotos(String momentId) async {
    final photoItems = (await momentsPhotoRef.child(momentId).listAll()).items;
    for (var element in photoItems) {
      await momentsPhotoRef.child(momentId).child(element.name).delete();
    }
  }

  @override
  Future deleteMomentPhoto(List<String> paths, String momentId) async {
    final photoItems = (await momentsPhotoRef.child(momentId).listAll()).items;
    for (final item in photoItems) {
      final url = await item.getDownloadURL();
      if (paths.contains(url)) {
        await momentsPhotoRef.child(momentId).child(item.name).delete();
      }
    }
  }

  static const String photosStorage = "photosStorage";
}
