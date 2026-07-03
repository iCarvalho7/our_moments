import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';
import 'package:nossos_momentos/modules/core/utils/logging/request_logger.dart';

import '../model/user_premium_model.dart';

abstract class UserPremiumDataSource {
  /// Reads `users/{uid}`. Tolerates a missing doc by returning null.
  Future<UserPremiumModel?> getByUid(String uid);

  /// Creates/updates `users/{uid}` with a set/merge.
  Future<UserPremiumModel> updatePremium(
    String uid, {
    required String email,
    required bool isPremium,
    DateTime? premiumUntil,
  });

  /// Deletes `users/{uid}`. A no-op when the doc does not exist.
  Future<void> delete(String uid);
}

@Injectable(as: UserPremiumDataSource)
class FirebaseUserPremiumDataSourceImpl extends UserPremiumDataSource {
  final CollectionReference<UserPremiumModel> usersRef;

  FirebaseUserPremiumDataSourceImpl(@Named('users') this.usersRef);

  @override
  Future<UserPremiumModel?> getByUid(String uid) => RequestLogger.track(
        'User.getByUid',
        params: {'uid': uid},
        request: () async {
          final snapshot = await usersRef.doc(uid).get();
          return snapshot.data();
        },
      );

  @override
  Future<UserPremiumModel> updatePremium(
    String uid, {
    required String email,
    required bool isPremium,
    DateTime? premiumUntil,
  }) =>
      RequestLogger.track(
        'User.updatePremium',
        params: {'uid': uid, 'isPremium': isPremium},
        request: () async {
          final model = UserPremiumModel(
            uid: uid,
            email: email,
            isPremium: isPremium,
            premiumUntil: premiumUntil,
          );

          await usersRef.doc(uid).set(model, SetOptions(merge: true));

          return (await usersRef.doc(uid).get()).data()!;
        },
      );

  @override
  Future<void> delete(String uid) => RequestLogger.track(
        'User.delete',
        params: {'uid': uid},
        request: () => usersRef.doc(uid).delete(),
      );
}
