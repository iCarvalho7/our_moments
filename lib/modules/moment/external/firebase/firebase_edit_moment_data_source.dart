import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';
import '../../infra/models/moment_model.dart';
import '../../infra/data_source/update_moment_data_source.dart';

@Injectable(as: UpdateMomentDataSource)
class FirebaseEditMomentDataSource extends UpdateMomentDataSource {

  final CollectionReference<MomentModel> momentsDataBaseRef;

  FirebaseEditMomentDataSource(@Named(momentsDBParam) this.momentsDataBaseRef);

  @override
  Future updateMoment(String momentId, Map<String, dynamic> momentModel) async {
    return await momentsDataBaseRef.doc(momentId).update(momentModel);
  }

  static const String momentsDBParam = "momentsDBParam";

}

