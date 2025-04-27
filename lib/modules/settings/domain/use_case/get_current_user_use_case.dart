import 'package:firebase_auth/firebase_auth.dart';
import 'package:injectable/injectable.dart';
import 'package:nossos_momentos/modules/core/use_case/use_case.dart';
import 'package:nossos_momentos/modules/login/domain/repository/auth_repository.dart';

@injectable
class GetCurrentUserUseCase extends UseCase<User?, NoParams> {

  final AuthRepository repository;

  GetCurrentUserUseCase(this.repository);

  @override
  User? execute(NoParams params) {
    return repository.getCurrentUser();
  }
}