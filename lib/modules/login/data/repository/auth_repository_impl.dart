import 'package:injectable/injectable.dart';
import 'package:nossos_momentos/modules/login/data/data_source/auth_remote_data_source.dart';
import 'package:nossos_momentos/modules/login/domain/repository/auth_repository.dart';

@Injectable(as: AuthRepository)
class AuthRepositoryImpl extends AuthRepository {

  final AuthRemoteDataSource dataSource;

  AuthRepositoryImpl(this.dataSource);

  @override
  Future<void> signIn(String username, String password) {
    return dataSource.signIn(username, password);
  }
}
