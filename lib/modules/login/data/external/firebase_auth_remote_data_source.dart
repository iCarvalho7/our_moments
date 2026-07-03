import 'package:firebase_auth/firebase_auth.dart';
import 'package:injectable/injectable.dart';
import 'package:nossos_momentos/modules/core/utils/logging/request_logger.dart';
import 'package:nossos_momentos/modules/login/data/data_source/auth_remote_data_source.dart';

@Injectable(as: AuthRemoteDataSource)
class FirebaseAuthRemoteDataSource extends AuthRemoteDataSource {
  final FirebaseAuth firebaseAuth;

  FirebaseAuthRemoteDataSource(this.firebaseAuth);

  @override
  Future<void> signIn(String username, String password) => RequestLogger.track(
        'Auth.signIn',
        params: {'email': username},
        request: () => firebaseAuth.signInWithEmailAndPassword(
          email: username,
          password: password,
        ),
      );

  @override
  Future<void> signUp(String username, String password) => RequestLogger.track(
        'Auth.signUp',
        params: {'email': username},
        request: () => firebaseAuth.createUserWithEmailAndPassword(
          email: username,
          password: password,
        ),
      );

  @override
  bool isUserAuthenticated() {
    return firebaseAuth.currentUser != null;
  }

  @override
  User? getCurrentUser() {
    return firebaseAuth.currentUser;
  }

  @override
  Future<void> logout() => RequestLogger.track(
        'Auth.logout',
        request: () => firebaseAuth.signOut(),
      );

  @override
  Future<void> reauthenticateWithPassword(String password) => RequestLogger.track(
        'Auth.reauthenticate',
        request: () async {
          final user = firebaseAuth.currentUser;
          final email = user?.email;
          if (user == null || email == null) {
            throw FirebaseAuthException(code: 'no-current-user');
          }
          final credential = EmailAuthProvider.credential(
            email: email,
            password: password,
          );
          await user.reauthenticateWithCredential(credential);
        },
      );

  @override
  Future<void> deleteAccount() => RequestLogger.track(
        'Auth.deleteAccount',
        request: () async {
          final user = firebaseAuth.currentUser;
          if (user == null) {
            throw FirebaseAuthException(code: 'no-current-user');
          }
          await user.delete();
        },
      );
}
