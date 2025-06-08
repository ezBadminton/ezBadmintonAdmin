part of 'login_bloc.dart';

/// Registration and login bloc
class LoginState extends Equatable with FormzMixin {
  const LoginState({
    this.status = FormzSubmissionStatus.initial,
    this.showValidationErrors = false,
    this.loginStatusCode = '',
    this.username = const NonEmptyInput.pure(),
    this.password = const NonEmptyInput.pure(minLength: 5),
  });

  final FormzSubmissionStatus status;
  final bool showValidationErrors;
  final String loginStatusCode;
  final NonEmptyInput username;
  final NonEmptyInput password;

  LoginState copyWith({
    FormzSubmissionStatus? status,
    bool? showValidationErrors,
    String? loginStatusCode,
    NonEmptyInput? username,
    NonEmptyInput? password,
  }) {
    return LoginState(
      status: status ?? this.status,
      showValidationErrors: showValidationErrors ?? this.showValidationErrors,
      loginStatusCode: loginStatusCode ?? this.loginStatusCode,
      username: username ?? this.username,
      password: password ?? this.password,
    );
  }

  @override
  List<Object> get props => [
        status,
        showValidationErrors,
        loginStatusCode,
        username,
        password,
      ];

  @override
  List<FormzInput> get inputs => [username, password];
}
