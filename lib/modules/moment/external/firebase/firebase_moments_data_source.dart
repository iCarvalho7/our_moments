import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';
import '../../infra/data_source/moments_data_source.dart';
import '../../infra/models/moment_model.dart';

@Injectable(as: MomentsDataSource)
class FirebaseMomentsDataSource extends MomentsDataSource {
  final CollectionReference<MomentModel> momentsDBRef;

  FirebaseMomentsDataSource(@Named(momentsDBParam) this.momentsDBRef);

  @override
  Future registerMoment({required MomentModel moment}) =>
      momentsDBRef.doc(moment.id).set(moment);

  @override
  Future<MomentModel> fetchMoment({
    required String momentId,
  }) async {
    final result = await momentsDBRef
        .where('id', isEqualTo: momentId)
        .get(const GetOptions(
          source: Source.server,
        ));

    return result.docs.first.data();
  }

  static const String momentsDBParam = "momentsDBParam";
}
