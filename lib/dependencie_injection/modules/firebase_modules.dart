import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';
import 'package:nossos_momentos/modules/time_line/external/firebase/firebase_timeline_data_sourse.dart';
import 'package:nossos_momentos/modules/time_line/infra/models/moment_model.dart';

@module
abstract class FirebaseModule {
  @Named(FirebaseTimeLineDataSource.momentsDBParam)
  CollectionReference<MomentModel> get momentsDBRef =>
      FirebaseFirestore.instance.collection('moments').withConverter(
            fromFirestore: ((snapshot, options) =>
                MomentModel.fromJson(snapshot.data()!)),
            toFirestore: (moments, options) => moments.toMap(),
          );
}
