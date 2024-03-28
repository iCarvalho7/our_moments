import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:nossos_momentos/modules/login/domain/use_case/sign_in_use_case.dart';

part 'login_event.dart';

part 'login_state.dart';

@injectable
class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc(
    this._signInUseCase,
  ) : super(LoginInitial()) {
    on<LoginEventSignIn>(_onSignIn);
  }

  final SignInUseCase _signInUseCase;

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
}
