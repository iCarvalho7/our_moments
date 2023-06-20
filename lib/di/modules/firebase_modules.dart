import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:injectable/injectable.dart';

import '../../modules/moment/external/firebase/firebase_moments_data_source.dart';
import '../../modules/moment/infra/models/moment_model.dart';
import '../../modules/photos/external/firebase_storage_photo_data_source.dart';

@module
abstract class FirebaseModule {
  @Named(FirebaseMomentsDataSource.momentsDBParam)
  CollectionReference<MomentModel> get momentsDBRef =>
      FirebaseFirestore.instance.collection('moments').withConverter(
            fromFirestore: ((snapshot, options) => MomentModel.fromJson(snapshot.data()!)),
            toFirestore: (moments, options) => moments.toJson(),
          );

  @Named(FirebaseStoragePhotoDataSource.photosStorage)
  Reference get momentsPhotoRef => FirebaseStorage.instance.ref().child('moments_photo');
}
