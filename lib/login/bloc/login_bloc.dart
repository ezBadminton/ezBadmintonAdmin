import 'dart:async';

import 'package:authentication_repository/authentication_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:ez_badminton_admin_app/constants.dart';
import 'package:ez_badminton_admin_app/input_models/non_empty.dart';
import 'package:flutter/material.dart';
import 'package:formz/formz.dart';

part 'login_event.dart';
part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc({
    required AuthenticationRepository<InfoscreenAuthCollectionName>
        authenticationRepository,
  })  : _authenticationRepository = authenticationRepository,
        super(const LoginState()) {
    on<LoginUsernameChanged>(_onUsernameChanged);
    on<LoginPasswordChanged>(_onPasswordChanged);
    on<LoginSubmitted>(_onSubmitted);
    on<LoginFailureDismissed>(_onLoginFailureDismissed);
  }

  final AuthenticationRepository _authenticationRepository;

  final TextEditingController usernameInputController = TextEditingController();
  final TextEditingController passwordInputController = TextEditingController();
  final TextEditingController passwordConfirmationController =
      TextEditingController();

  void _onUsernameChanged(
    LoginUsernameChanged event,
    Emitter<LoginState> emit,
  ) {
    final username = NonEmptyInput.dirty(value: event.username);
    emit(state.copyWith(username: username));
  }

  void _onPasswordChanged(
    LoginPasswordChanged event,
    Emitter<LoginState> emit,
  ) {
    final password = state.password.copyWith(event.password);
    emit(state.copyWith(password: password));
  }

  Future<void> _onSubmitted(
    LoginSubmitted event,
    Emitter<LoginState> emit,
  ) async {
    emit(state.copyWith(showValidationErrors: true));

    if (!state.isValid) {
      return;
    }

    emit(state.copyWith(status: FormzSubmissionStatus.inProgress));
    try {
      await _authenticationRepository.logIn(
        username: state.username.value,
        password: state.password.value,
      );

      emit(state.copyWith(
        status: FormzSubmissionStatus.success,
        username: const NonEmptyInput.pure(),
        password: const NonEmptyInput.pure(minLength: 5),
        showValidationErrors: false,
      ));
      usernameInputController.text = '';
      passwordInputController.text = '';
      passwordConfirmationController.text = '';
    } on LoginException catch (e) {
      emit(state.copyWith(
        status: FormzSubmissionStatus.failure,
        loginStatusCode: e.statusCode,
      ));
    }
  }

  FutureOr<void> _onLoginFailureDismissed(
    LoginFailureDismissed event,
    Emitter<LoginState> emit,
  ) {
    emit(state.copyWith(status: FormzSubmissionStatus.initial));
  }
}
