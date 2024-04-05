import 'dart:async';

import 'package:authentication_repository/authentication_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:ez_badminton_admin_app/input_models/equal_input.dart';
import 'package:ez_badminton_admin_app/input_models/non_empty.dart';
import 'package:flutter/material.dart';
import 'package:formz/formz.dart';

part 'login_event.dart';
part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc({
    required AuthenticationRepository authenticationRepository,
  })  : _authenticationRepository = authenticationRepository,
        super(const LoginState()) {
    on<LoginUsernameChanged>(_onUsernameChanged);
    on<LoginPasswordChanged>(_onPasswordChanged);
    on<LoginPasswordConfirmationChanged>(_onPasswordConfirmationChanged);
    on<LoginSubmitted>(_onSubmitted);
    on<LoginFailureDismissed>(_onLoginFailureDismissed);
    on<RegistrationStatusChanged>(_onRegistrationStatusChanged);

    _fetchRegistrationStatus();
  }

  final AuthenticationRepository _authenticationRepository;

  final TextEditingController usernameInputController = TextEditingController();
  final TextEditingController passwordInputController = TextEditingController();
  final TextEditingController passwordConfirmationController =
      TextEditingController();

  void _fetchRegistrationStatus() async {
    add(const RegistrationStatusChanged(RegistrationStatus.unknown));

    bool isRegistered = await _authenticationRepository.isRegistered();

    if (isRegistered) {
      add(const RegistrationStatusChanged(RegistrationStatus.registered));
    } else {
      add(const RegistrationStatusChanged(RegistrationStatus.notRegistered));
    }
  }

  void _onRegistrationStatusChanged(
    RegistrationStatusChanged event,
    Emitter<LoginState> emit,
  ) {
    LoginState newState = state.copyWith(
      registrationStatus: event.registrationStatus,
    );
    emit(newState);
  }

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

    EqualInput passwordConfirmation = state.passwordConfirmation;
    if (state.registrationStatus == RegistrationStatus.notRegistered) {
      passwordConfirmation = EqualInput.dirty(
        event.password,
        state.passwordConfirmation.value,
      );
    }

    emit(state.copyWith(
      password: password,
      passwordConfirmation: passwordConfirmation,
    ));
  }

  void _onPasswordConfirmationChanged(
    LoginPasswordConfirmationChanged event,
    Emitter<LoginState> emit,
  ) {
    final passwordConfirmation = EqualInput.dirty(
      state.password.value,
      event.passwordConfirmation,
    );

    emit(state.copyWith(passwordConfirmation: passwordConfirmation));
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
      if (state.registrationStatus == RegistrationStatus.registered) {
        await _authenticationRepository.logIn(
          username: state.username.value,
          password: state.password.value,
        );
      } else if (state.registrationStatus == RegistrationStatus.notRegistered) {
        await _authenticationRepository.signUp(
          username: state.username.value,
          password: state.password.value,
        );
      } else {
        throw LoginException("Can't submit with unknown registration status");
      }
      _fetchRegistrationStatus();

      emit(state.copyWith(
        status: FormzSubmissionStatus.success,
        username: const NonEmptyInput.pure(),
        password: const NonEmptyInput.pure(minLength: 5),
        passwordConfirmation: const EqualInput.pure(''),
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
      _fetchRegistrationStatus();
    }
  }

  FutureOr<void> _onLoginFailureDismissed(
    LoginFailureDismissed event,
    Emitter<LoginState> emit,
  ) {
    emit(state.copyWith(status: FormzSubmissionStatus.initial));
  }
}
