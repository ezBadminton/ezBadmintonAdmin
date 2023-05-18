import 'package:authentication_repository/authentication_repository.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:ez_badminton_admin_app/input_models/non_empty.dart';
import 'package:ez_badminton_admin_app/login/bloc/login_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:formz/formz.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthenticationRepository extends Mock
    implements AuthenticationRepository {}

void main() {
  late LoginBloc sut;
  late MockAuthenticationRepository authenticationRepository;

  setUp(() {
    authenticationRepository = MockAuthenticationRepository();
    when(
      () => authenticationRepository.logIn(
        username: any(named: 'username'),
        password: any(named: 'password'),
      ),
    ).thenAnswer((invocation) async {
      String username = invocation.namedArguments[#username];
      String password = invocation.namedArguments[#password];
      if (username != 'test' || password != '12345') {
        throw LoginException('400');
      }
    });
    sut = LoginBloc(authenticationRepository: authenticationRepository);
  });

  group('LoginBloc', () {
    blocTest<LoginBloc, LoginState>(
      'emits validated password and unsername on change events.',
      build: () => sut,
      act: (bloc) {
        bloc.add(const LoginUsernameChanged('adim'));
        bloc.add(const LoginPasswordChanged('mypass'));
      },
      expect: () => const <LoginState>[
        LoginState(
          username: NonEmptyInput.dirty('adim'),
          validated: false,
        ),
        LoginState(
          username: NonEmptyInput.dirty('adim'),
          password: NonEmptyInput.dirty('mypass'),
          validated: true,
        ),
      ],
    );

    blocTest<LoginBloc, LoginState>(
      """Only calls AuthenticationRepository.logIn when username and
      password are present""",
      build: () => sut,
      act: (bloc) {
        bloc.add(const LoginUsernameChanged('adim'));
        bloc.add(const LoginSubmitted()); // Submit with missing password
        bloc.add(const LoginUsernameChanged(''));
        bloc.add(const LoginPasswordChanged('mypass'));
        bloc.add(const LoginSubmitted()); // Submit with missing username
        bloc.add(const LoginUsernameChanged('adim'));
        bloc.add(const LoginSubmitted()); // Submit valid username + password
      },
      verify: (_) => verify(() => authenticationRepository.logIn(
            username: any(named: 'username'),
            password: any(named: 'password'),
          )).called(1),
    );

    const wrongCredentialState = LoginState(
      username: NonEmptyInput.dirty('username'),
      password: NonEmptyInput.dirty('wrongPassword'),
      validated: true,
    );
    final wrongCredentialsSubmittedState = wrongCredentialState.copyWith(
      showValidationErrors: true,
    );
    final loadingFailureState = wrongCredentialsSubmittedState.copyWith(
      status: FormzSubmissionStatus.inProgress,
    );
    final failureState = loadingFailureState.copyWith(
      loginStatusCode: '400',
      status: FormzSubmissionStatus.failure,
    );
    blocTest<LoginBloc, LoginState>(
      """Emits FormzSubmissionStatus.failure and a loginStatusCode
      when login fails""",
      build: () => sut,
      seed: () => wrongCredentialState,
      act: (bloc) => bloc.add(const LoginSubmitted()),
      expect: () => <LoginState>[
        wrongCredentialsSubmittedState,
        loadingFailureState,
        failureState,
      ],
    );

    const correctCredentialState = LoginState(
      username: NonEmptyInput.dirty('test'),
      password: NonEmptyInput.dirty('12345'),
      validated: true,
    );
    final correctCredentialsSubmittedState = correctCredentialState.copyWith(
      showValidationErrors: true,
    );
    final loadingSuccessState = correctCredentialsSubmittedState.copyWith(
      status: FormzSubmissionStatus.inProgress,
    );
    final successState = loadingSuccessState.copyWith(
      status: FormzSubmissionStatus.success,
    );
    blocTest<LoginBloc, LoginState>(
      'Emits FormzSubmissionStatus.success when login succeeds',
      build: () => sut,
      seed: () => correctCredentialState,
      act: (bloc) => bloc.add(const LoginSubmitted()),
      expect: () => <LoginState>[
        correctCredentialsSubmittedState,
        loadingSuccessState,
        successState,
      ],
    );

    blocTest<LoginBloc, LoginState>(
      'Emits FormzSubmissionStatus.initial when failure is dismissed',
      build: () => sut,
      seed: () => const LoginState(status: FormzSubmissionStatus.failure),
      act: (bloc) => bloc.add(const LoginFailureDismissed()),
      expect: () =>
          const <LoginState>[LoginState(status: FormzSubmissionStatus.initial)],
    );
  });
}
