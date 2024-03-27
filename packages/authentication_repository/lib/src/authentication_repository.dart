import 'dart:async';
import 'package:pocketbase_provider/pocketbase_provider.dart';
import 'package:pocketbase/pocketbase.dart';

enum AuthenticationStatus { unknown, authenticated, unauthenticated }

class AuthenticationRepository {
  final _controller = StreamController<AuthenticationStatus>();
  final PocketBaseProvider _pocketBaseProvider;
  final PocketBase pocketBase;

  AuthenticationRepository({required PocketBaseProvider pocketBaseProvider})
      : _pocketBaseProvider = pocketBaseProvider,
        pocketBase = pocketBaseProvider.pocketBase {
    _pocketBaseProvider.whenAvailable
        .then((_) => _controller.add(AuthenticationStatus.unauthenticated));
  }

  Stream<AuthenticationStatus> get status async* {
    yield AuthenticationStatus.unknown;
    yield* _controller.stream;
  }

  /// Queries the server to find wether an organizer user is registered
  Future<bool> isRegistered() async {
    Map<String, dynamic> result;
    try {
      result =
          await pocketBase.send("/api/ezbadminton/tournament_organizer/exists");
    } on ClientException catch (e) {
      throw LoginException('${e.statusCode}');
    }

    bool exists = result["OrganizerUserExists"];

    return exists;
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

  Future<void> signUp({
    required String username,
    required String password,
  }) async {
    try {
      await pocketBase.collection('tournament_organizer').create(body: {
        "username": username,
        "password": password,
        "passwordConfirm": password,
      });
    } on ClientException catch (e) {
      throw LoginException('${e.statusCode}');
    }
  }

  void dispose() => _controller.close();
}

class LoginException implements Exception {
  LoginException(this.statusCode);
  final String statusCode;
}
