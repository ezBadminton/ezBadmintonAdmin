part of 'login_bloc.dart';

class LoginState extends Equatable {
  const LoginState({
    this.status = FormzSubmissionStatus.initial,
    this.validated = false,
    this.showValidationErrors = false,
    this.loginStatusCode = '',
    this.username = const NonEmptyInput.pure(),
    this.password = const NonEmptyInput.pure(),
  });

  final FormzSubmissionStatus status;
  final bool validated;
  final bool showValidationErrors;
  final String loginStatusCode;
  final NonEmptyInput username;
  final NonEmptyInput password;

  LoginState copyWith({
    FormzSubmissionStatus? status,
    bool? validated,
    bool? showValidationErrors,
    String? loginStatusCode,
    NonEmptyInput? username,
    NonEmptyInput? password,
  }) {
    return LoginState(
      status: status ?? this.status,
      validated: validated ?? this.validated,
      showValidationErrors: showValidationErrors ?? this.showValidationErrors,
      loginStatusCode: loginStatusCode ?? this.loginStatusCode,
      username: username ?? this.username,
      password: password ?? this.password,
    );
  }

  @override
  List<Object> get props => [
        status,
        validated,
        showValidationErrors,
        loginStatusCode,
        username,
        password,
      ];
}
