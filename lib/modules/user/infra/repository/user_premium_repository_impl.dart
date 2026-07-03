import 'package:injectable/injectable.dart';

import '../../domain/entity/user_premium.dart';
import '../../domain/repository/user_premium_repository.dart';
import '../data_source/user_premium_data_source.dart';

@Injectable(as: UserPremiumRepository)
class UserPremiumRepositoryImpl extends UserPremiumRepository {
  final UserPremiumDataSource dataSource;

  UserPremiumRepositoryImpl(this.dataSource);

  @override
  Future<UserPremium?> getByUid(String uid) {
    return dataSource.getByUid(uid);
  }

  @override
  Future<UserPremium> updatePremium(
    String uid, {
    required String email,
    required bool isPremium,
    DateTime? premiumUntil,
  }) {
    return dataSource.updatePremium(
      uid,
      email: email,
      isPremium: isPremium,
      premiumUntil: premiumUntil,
    );
  }

  @override
  Future<void> delete(String uid) {
    return dataSource.delete(uid);
  }
}
