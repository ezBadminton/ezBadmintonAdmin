// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'info_screen_user_registration_cubit.dart';

class InfoScreenUserRegistrationState with FormzMixin {
  InfoScreenUserRegistrationState({
    this.status = FormzSubmissionStatus.initial,
    this.showValidationErrors = false,
    this.loginStatusCode = '',
    this.username = const NonEmptyInput.pure(minLength: 3),
    this.password = const NonEmptyInput.pure(minLength: 5),
    this.passwordConfirmation = const EqualInput.pure(''),
  });

  final FormzSubmissionStatus status;
  final bool showValidationErrors;
  final String loginStatusCode;
  final NonEmptyInput username;
  final NonEmptyInput password;
  final EqualInput passwordConfirmation;

  InfoScreenUserRegistrationState copyWith({
    FormzSubmissionStatus? status,
    bool? showValidationErrors,
    String? loginStatusCode,
    NonEmptyInput? username,
    NonEmptyInput? password,
    EqualInput? passwordConfirmation,
  }) {
    return InfoScreenUserRegistrationState(
      status: status ?? this.status,
      showValidationErrors: showValidationErrors ?? this.showValidationErrors,
      loginStatusCode: loginStatusCode ?? this.loginStatusCode,
      username: username ?? this.username,
      password: password ?? this.password,
      passwordConfirmation: passwordConfirmation ?? this.passwordConfirmation,
    );
  }

  @override
  List<FormzInput> get inputs => [username, password, passwordConfirmation];
}
