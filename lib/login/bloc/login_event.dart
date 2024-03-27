part of 'login_bloc.dart';

abstract class LoginEvent extends Equatable {
  const LoginEvent();

  @override
  List<Object> get props => [];
}

class LoginUsernameChanged extends LoginEvent {
  const LoginUsernameChanged(this.username);

  final String username;

  @override
  List<Object> get props => [username];
}

class LoginPasswordChanged extends LoginEvent {
  const LoginPasswordChanged(this.password);

  final String password;

  @override
  List<Object> get props => [password];
}

class LoginPasswordConfirmationChanged extends LoginEvent {
  const LoginPasswordConfirmationChanged(this.passwordConfirmation);

  final String passwordConfirmation;

  @override
  List<Object> get props => [passwordConfirmation];
}

class LoginSubmitted extends LoginEvent {
  const LoginSubmitted();
}

class LoginFailureDismissed extends LoginEvent {
  const LoginFailureDismissed();
}

class RegistrationStatusChanged extends LoginEvent {
  const RegistrationStatusChanged(this.registrationStatus);

  final RegistrationStatus registrationStatus;

  @override
  List<Object> get props => [registrationStatus];
}
