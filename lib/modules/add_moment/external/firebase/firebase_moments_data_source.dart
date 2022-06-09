import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';
import 'package:nossos_momentos/modules/add_moment/infra/data_source/moments_data_source.dart';
import 'package:nossos_momentos/modules/add_moment/infra/models/moment_model.dart';

@Injectable(as: MomentsDataSource)
class FirebaseMomentsDataSource extends MomentsDataSource {
  final CollectionReference<MomentModel> momentsDBRef;

  FirebaseMomentsDataSource(@Named(momentsDBParam) this.momentsDBRef);

  @override
  Future registerMoment({required MomentModel moment}) =>
      momentsDBRef.add(moment);

  static const String momentsDBParam = "momentsDBParam";
}
