part of 'login_bloc.dart';

/// Registration and login bloc
class LoginState extends Equatable with FormzMixin {
  const LoginState({
    this.status = FormzSubmissionStatus.initial,
    this.showValidationErrors = false,
    this.loginStatusCode = '',
    this.username = const NonEmptyInput.pure(),
    this.password = const NonEmptyInput.pure(minLength: 5),
    this.passwordConfirmation = const EqualInput.pure(''),
    this.registrationStatus = RegistrationStatus.unknown,
  });

  final FormzSubmissionStatus status;
  final bool showValidationErrors;
  final String loginStatusCode;
  final NonEmptyInput username;
  final NonEmptyInput password;
  final EqualInput passwordConfirmation;
  final RegistrationStatus registrationStatus;

  LoginState copyWith({
    FormzSubmissionStatus? status,
    bool? showValidationErrors,
    String? loginStatusCode,
    NonEmptyInput? username,
    NonEmptyInput? password,
    EqualInput? passwordConfirmation,
    RegistrationStatus? registrationStatus,
  }) {
    return LoginState(
      status: status ?? this.status,
      showValidationErrors: showValidationErrors ?? this.showValidationErrors,
      loginStatusCode: loginStatusCode ?? this.loginStatusCode,
      username: username ?? this.username,
      password: password ?? this.password,
      passwordConfirmation: passwordConfirmation ?? this.passwordConfirmation,
      registrationStatus: registrationStatus ?? this.registrationStatus,
    );
  }

  @override
  List<Object> get props => [
        status,
        showValidationErrors,
        loginStatusCode,
        username,
        password,
        passwordConfirmation,
        registrationStatus,
      ];

  @override
  List<FormzInput> get inputs => [username, password, passwordConfirmation];
}

enum RegistrationStatus {
  unknown,
  registered,
  notRegistered,
}
