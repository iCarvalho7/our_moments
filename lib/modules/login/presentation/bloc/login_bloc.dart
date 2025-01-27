import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:nossos_momentos/modules/core/use_case/use_case.dart';
import 'package:nossos_momentos/modules/login/domain/use_case/is_user_authenticated_use_case.dart';
import 'package:nossos_momentos/modules/login/domain/use_case/sign_in_use_case.dart';

part 'login_event.dart';

part 'login_state.dart';

@injectable
class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc(
    this._signInUseCase,
    this._isUserAuthenticatedUseCase,
  ) : super(LoginInitial()) {
    on<LoginEventSignIn>(_onSignIn);
    on<LoginEventValidateUser>(_validateUser);
  }

  final SignInUseCase _signInUseCase;
  final IsUserAuthenticatedUseCase _isUserAuthenticatedUseCase;

  FutureOr<void> _onSignIn(
    LoginEventSignIn event,
    Emitter<LoginState> emit,
  ) async {
    emit(LoginLoading());

    final result = await _signInUseCase.call(SignInParam(
      event.username,
      event.password,
    ));

    if (result.isError) {
      emit(LoginError());
      return;
    }

    emit(LoginSuccess());
  }

  FutureOr<void> _validateUser(
    LoginEventValidateUser event,
    Emitter<LoginState> emit,
  ) async {
    final result = _isUserAuthenticatedUseCase.call(NoParams.instance);

    if (result.data == true) {
      emit(LoginSuccess());
      return;
    }
  }
}
