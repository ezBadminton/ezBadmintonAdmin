import 'package:authentication_repository/authentication_repository.dart';
import 'package:ez_badminton_admin_app/authentication/authentication.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:user_repository/user_repository.dart';
import 'package:bloc_test/bloc_test.dart';

class MockAuthenticationRepository extends Mock
    implements AuthenticationRepository {}

class MockUserRepository extends Mock implements UserRepository {}

void main() {
  late MockAuthenticationRepository authenticationRepository;
  late MockUserRepository userRepository;

  setUp(() {
    authenticationRepository = MockAuthenticationRepository();
    userRepository = MockUserRepository();
    when(() => userRepository.getUser()).thenAnswer(
      (_) async => const User('userid'),
    );
  });

  void arrangeAuthenticationRepositoryStreams(
      List<AuthenticationStatus> status) {
    when(() => authenticationRepository.status)
        .thenAnswer((_) => Stream<AuthenticationStatus>.fromIterable(status));
  }

  group('AuthenticationBloc', () {
    test(
      'initial state is AuthenticationState.unknown()',
      () {
        arrangeAuthenticationRepositoryStreams([]);
        var bloc = AuthenticationBloc(
          authenticationRepository: authenticationRepository,
          userRepository: userRepository,
        );
        expect(bloc.state, const AuthenticationState.unknown());
      },
    );

    blocTest<AuthenticationBloc, AuthenticationState>(
      """emits [AuthenticationState.unknown()] when AuthenticationRepository
      streams AuthenticationStatus.unknown""",
      setUp: () => arrangeAuthenticationRepositoryStreams(
          [AuthenticationStatus.unknown]),
      build: () => AuthenticationBloc(
        authenticationRepository: authenticationRepository,
        userRepository: userRepository,
      ),
      expect: () => const <AuthenticationState>[AuthenticationState.unknown()],
    );

    blocTest<AuthenticationBloc, AuthenticationState>(
      """emits [AuthenticationState.unauthenticated()] when
      AuthenticationRepository streams AuthenticationStatus.unauthenticated""",
      setUp: () => arrangeAuthenticationRepositoryStreams(
          [AuthenticationStatus.unauthenticated]),
      build: () => AuthenticationBloc(
        authenticationRepository: authenticationRepository,
        userRepository: userRepository,
      ),
      expect: () =>
          const <AuthenticationState>[AuthenticationState.unauthenticated()],
    );

    blocTest<AuthenticationBloc, AuthenticationState>(
      """emits [AuthenticationState.authenticated(User('userid'))] when 
      AuthenticationRepository streams AuthenticationStatus.authenticated""",
      setUp: () => arrangeAuthenticationRepositoryStreams(
          [AuthenticationStatus.authenticated]),
      build: () => AuthenticationBloc(
        authenticationRepository: authenticationRepository,
        userRepository: userRepository,
      ),
      expect: () => const <AuthenticationState>[
        AuthenticationState.authenticated(User('userid')),
      ],
    );

    blocTest<AuthenticationBloc, AuthenticationState>(
      """calls AuthenticationRepository.logOut when 
      [AuthenticationLogoutRequested] is added""",
      setUp: () => arrangeAuthenticationRepositoryStreams(
          [AuthenticationStatus.authenticated]),
      build: () => AuthenticationBloc(
        authenticationRepository: authenticationRepository,
        userRepository: userRepository,
      ),
      act: (bloc) => bloc.add(AuthenticationLogoutRequested()),
      verify: (_) => verify(() => authenticationRepository.logOut()).called(1),
    );
  });
}
