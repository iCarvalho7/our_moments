import 'dart:async';
import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:injectable/injectable.dart';
import 'package:nossos_momentos/modules/upload_photo/infra/data_source/photo_data_source.dart';

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
    final child = "$id/${image.path}";
    final uploadTask = momentsPhotoRef.child(child).putFile(image);
    String downloadUrl = '';

    await uploadTask.then((TaskSnapshot task) async {
      downloadUrl = await task.ref.getDownloadURL();
    });

    return downloadUrl;
  }

  static const String photosStorage = "photosStorage";
}
