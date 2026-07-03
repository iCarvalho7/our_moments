import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:injectable/injectable.dart';
import 'package:nossos_momentos/modules/time_line/infra/model/time_line_model.dart';
import 'package:nossos_momentos/modules/user/infra/model/user_premium_model.dart';

import '../../modules/moment/external/firebase/firebase_moments_data_source.dart';
import '../../modules/moment/infra/models/moment_model.dart';
import '../../modules/moment/interactions/external/firebase/firebase_interactions_data_source.dart';
import '../../modules/photos/external/firebase_storage_photo_data_source.dart';
import '../../modules/time_line/bucket_list/external/firebase/firebase_bucket_list_data_source.dart';

@module
abstract class FirebaseModule {
  @Named(FirebaseMomentsDataSource.momentsDBParam)
  CollectionReference<MomentModel> get momentsDBRef =>
      FirebaseFirestore.instance.collection('moments').withConverter(
            fromFirestore: ((snapshot, options) => MomentModel.fromJson(snapshot.data()!)),
            toFirestore: (moments, options) => moments.toJson(),
          );

  @Named('timeline')
  CollectionReference<TimeLineModel> get timelineDbRef =>
      FirebaseFirestore.instance.collection('time_line').withConverter(
            fromFirestore: ((snapshot, options) => TimeLineModel.fromJson(snapshot.data()!)),
            toFirestore: (moments, options) => moments.toJson(),
          );

  @Named('users')
  CollectionReference<UserPremiumModel> get usersDbRef =>
      FirebaseFirestore.instance.collection('users').withConverter(
            fromFirestore: ((snapshot, options) =>
                UserPremiumModel.fromJson(snapshot.data()!, uid: snapshot.id)),
            toFirestore: (user, options) => user.toJson(),
          );

  @Named(FirebaseStoragePhotoDataSource.photosStorage)
  Reference get momentsPhotoRef => FirebaseStorage.instance.ref().child('moments_photo');

  FirebaseAuth get firebaseAuth => FirebaseAuth.instance;

  FirebaseRemoteConfig get remoteConfig => FirebaseRemoteConfig.instance;

  @Named(FirebaseInteractionsDataSource.momentsRawCollectionParam)
  CollectionReference<Map<String, dynamic>> get momentsRawCollectionRef =>
      FirebaseFirestore.instance.collection('moments');

  @Named(FirebaseBucketListDataSource.timeLineRawCollectionParam)
  CollectionReference<Map<String, dynamic>> get timeLineRawCollectionRef =>
      FirebaseFirestore.instance.collection('time_line');
}
