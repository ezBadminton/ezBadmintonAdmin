import 'package:authentication_repository/authentication_repository.dart';
import 'package:ez_badminton_admin_app/constants.dart';
import 'package:ez_badminton_admin_app/input_models/equal_input.dart';
import 'package:ez_badminton_admin_app/input_models/models.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';

part 'info_screen_user_registration_state.dart';

class InfoScreenUserRegistrationCubit
    extends Cubit<InfoScreenUserRegistrationState> {
  InfoScreenUserRegistrationCubit({
    required SignupRepository<InfoscreenAuthCollectionName>
        authenticationRepository,
  })  : _authenticationRepository = authenticationRepository,
        super(InfoScreenUserRegistrationState());

  final SignupRepository<InfoscreenAuthCollectionName>
      _authenticationRepository;

  void userNameChanged(String username) {
    final usernameInput = state.username.copyWith(username);
    emit(state.copyWith(username: usernameInput));
  }

  void passwordChanged(String password) {
    final passwordInput = state.password.copyWith(password);

    EqualInput passwordConfirmation = state.passwordConfirmation;
    passwordConfirmation = EqualInput.dirty(
      password,
      state.passwordConfirmation.value,
    );

    emit(state.copyWith(
      password: passwordInput,
      passwordConfirmation: passwordConfirmation,
    ));
  }

  void passwordConfirmationChanged(String passwordConfirmation) {
    final passwordConfirmationInput = EqualInput.dirty(
      state.password.value,
      passwordConfirmation,
    );

    emit(state.copyWith(passwordConfirmation: passwordConfirmationInput));
  }

  void submitted() async {
    emit(state.copyWith(showValidationErrors: true));

    if (state.status == FormzSubmissionStatus.inProgress || state.isNotValid) {
      return;
    }

    emit(state.copyWith(status: FormzSubmissionStatus.inProgress));

    try {
      await _authenticationRepository.signUp(
        username: state.username.value,
        password: state.password.value,
      );
      emit(state.copyWith(status: FormzSubmissionStatus.success));
    } on LoginException catch (e) {
      emit(state.copyWith(
        status: FormzSubmissionStatus.failure,
        loginStatusCode: e.statusCode,
      ));
    }
  }
}
