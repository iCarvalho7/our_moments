import 'package:firebase_auth/firebase_auth.dart';
import 'package:injectable/injectable.dart';
import 'package:nossos_momentos/modules/login/data/data_source/auth_remote_data_source.dart';

@Injectable(as: AuthRemoteDataSource)
class FirebaseAuthRemoteDataSource extends AuthRemoteDataSource {
  final FirebaseAuth firebaseAuth;

  FirebaseAuthRemoteDataSource(this.firebaseAuth);

  @override
  Future<void> signIn(String username, String password) {
    return firebaseAuth.signInWithEmailAndPassword(
      email: username,
      password: password,
    );
  }
}
