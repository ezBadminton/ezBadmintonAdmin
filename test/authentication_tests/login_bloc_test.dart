import 'package:authentication_repository/authentication_repository.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:ez_badminton_admin_app/input_models/non_empty.dart';
import 'package:ez_badminton_admin_app/login/bloc/login_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:formz/formz.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthenticationRepository extends Mock
    implements AuthenticationRepository {}

class HasStatus extends CustomMatcher {
  HasStatus(matcher)
      : super(
          'State with status of',
          'FormzSubmissionStatus',
          matcher,
        );
  @override
  featureValueOf(actual) => actual.status;
}

class HasRegistrationStatus extends CustomMatcher {
  HasRegistrationStatus(matcher)
      : super(
          'State with RegistrationStatus of',
          'RegistrationStatus',
          matcher,
        );
  @override
  featureValueOf(actual) => actual.registrationStatus;
}

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
    when(
      () => authenticationRepository.isRegistered(),
    ).thenAnswer((invocation) async {
      return true;
    });
    sut = LoginBloc(authenticationRepository: authenticationRepository);
  });

  group('LoginBloc', () {
    blocTest<LoginBloc, LoginState>(
      'emits validated password and unsername on change events.',
      build: () => sut,
      act: (bloc) async {
        await Future.delayed(const Duration(milliseconds: 2));
        bloc.add(const LoginUsernameChanged('adim'));
        bloc.add(const LoginPasswordChanged('mypass'));
      },
      expect: () => [
        const LoginState(
          username: NonEmptyInput.dirty(value: 'adim'),
          registrationStatus: RegistrationStatus.registered,
        ),
        const LoginState(
          username: NonEmptyInput.dirty(value: 'adim'),
          password: NonEmptyInput.dirty(value: 'mypass'),
          registrationStatus: RegistrationStatus.registered,
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
      username: NonEmptyInput.dirty(value: 'username'),
      password: NonEmptyInput.dirty(value: 'wrongPassword'),
      registrationStatus: RegistrationStatus.registered,
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
      act: (bloc) async {
        await Future.delayed(const Duration(milliseconds: 2));
        bloc.add(const LoginSubmitted());
      },
      expect: () => [
        wrongCredentialsSubmittedState,
        loadingFailureState,
        HasRegistrationStatus(RegistrationStatus.registered),
        HasRegistrationStatus(RegistrationStatus.unknown),
        failureState,
      ],
    );

    const correctCredentialState = LoginState(
      username: NonEmptyInput.dirty(value: 'test'),
      password: NonEmptyInput.dirty(value: '12345'),
      registrationStatus: RegistrationStatus.registered,
    );
    final correctCredentialsSubmittedState = correctCredentialState.copyWith(
      showValidationErrors: true,
    );

    blocTest<LoginBloc, LoginState>(
      'Emits FormzSubmissionStatus.success when login succeeds',
      build: () => sut,
      seed: () => correctCredentialState,
      act: (bloc) async {
        await Future.delayed(const Duration(milliseconds: 20));

        bloc.add(const LoginSubmitted());
      },
      expect: () => [
        correctCredentialsSubmittedState,
        HasStatus(FormzSubmissionStatus.inProgress),
        HasStatus(FormzSubmissionStatus.success),
        HasRegistrationStatus(RegistrationStatus.unknown),
        HasRegistrationStatus(RegistrationStatus.registered),
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
