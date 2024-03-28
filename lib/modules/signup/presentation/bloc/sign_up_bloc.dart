import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:nossos_momentos/modules/login/domain/use_case/sign_in_use_case.dart';
import 'package:nossos_momentos/modules/signup/domain/sign_up_use_case.dart';

part 'sign_up_event.dart';

part 'sign_up_state.dart';

@injectable
class SignUpBloc extends Bloc<SignUpEvent, SignUpState> {
  SignUpBloc(this._signUpUseCase) : super(SignUpInitial()) {
    on<SignUpEventCreateAccount>(_signUp);
  }

  final SignUpUseCase _signUpUseCase;

  FutureOr<void> _signUp(
    SignUpEventCreateAccount event,
    Emitter<SignUpState> emit,
  ) async {
    emit(SignUpLoading());

    final res =
        await _signUpUseCase.call(SignInParam(event.username, event.password));

    if (res.isError) {
      emit(SignUpError());
      return;
    }

    emit(SignUpSuccess());
  }
}
