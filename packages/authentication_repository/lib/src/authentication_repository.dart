import 'dart:async';
import 'package:pocketbase_provider/pocketbase_provider.dart';
import 'package:pocketbase/pocketbase.dart';

enum AuthenticationStatus { unknown, authenticated, unauthenticated }

class AuthenticationRepository {
  final _controller = StreamController<AuthenticationStatus>();
  final _pocketBaseRepository = PocketBaseProvider();
  final pocketBase = PocketBaseProvider().pocketBase;

  AuthenticationRepository() {
    _pocketBaseRepository.whenAvailable
        .then((_) => _controller.add(AuthenticationStatus.unauthenticated));
  }

  Stream<AuthenticationStatus> get status async* {
    yield AuthenticationStatus.unknown;
    yield* _controller.stream;
  }

  Future<void> logIn({
    required String username,
    required String password,
  }) async {
    try {
      await pocketBase
          .collection('tournament_organizer')
          .authWithPassword(username, password);
      _controller.add(AuthenticationStatus.authenticated);
    } on ClientException catch (e) {
      throw LoginException('${e.statusCode}');
    }
  }

  void logOut() {
    pocketBase.authStore.clear();
    _controller.add(AuthenticationStatus.unauthenticated);
  }

  void dispose() => _controller.close();
}

class LoginException implements Exception {
  LoginException(this.statusCode);
  final String statusCode;
}
