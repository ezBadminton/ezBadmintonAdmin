// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';

import 'package:pocketbase/pocketbase.dart';
import 'package:pocketbase_provider/pocketbase_provider.dart';

enum AuthenticationStatus { unknown, authenticated, unauthenticated }

abstract class AuthCollectionName {
  const AuthCollectionName();
  String get authCollectionName;
}

class SignupRepository<A extends AuthCollectionName> {
  SignupRepository({
    required this.pocketBase,
    required this.authCollectionName,
  });

  final PocketBase pocketBase;
  final A authCollectionName;

  Future<void> signUp({
    required String username,
    required String password,
  }) async {
    try {
      await pocketBase
          .collection(authCollectionName.authCollectionName)
          .create(body: {
        "username": username,
        "password": password,
        "passwordConfirm": password,
      });
    } on ClientException catch (e) {
      throw LoginException('${e.statusCode}');
    }
  }
}

class AuthenticationRepository<A extends AuthCollectionName> {
  final _controller = StreamController<AuthenticationStatus>.broadcast();
  final PocketBaseProvider _pocketBaseProvider;
  final PocketBase pocketBase;
  final A authCollectionName;

  AuthenticationStatus _status = AuthenticationStatus.unknown;

  AuthenticationRepository({
    required PocketBaseProvider pocketBaseProvider,
    required this.authCollectionName,
  })  : _pocketBaseProvider = pocketBaseProvider,
        pocketBase = pocketBaseProvider.pocketBase {
    _pocketBaseProvider.connectivitySteam.listen(handlePocketBaseConnection);
  }

  Stream<AuthenticationStatus> get status => _controller.stream;

  void handlePocketBaseConnection(ConnectionEvent e) {
    switch (e) {
      case ConnectionEvent.connected:
        _status = _pocketBaseProvider.pocketBase.authStore.isValid
            ? AuthenticationStatus.authenticated
            : AuthenticationStatus.unauthenticated;
        _controller.add(_status);
      case ConnectionEvent.disconnected:
        _status = AuthenticationStatus.unknown;
        _controller.add(_status);
    }
  }

  Future<void> logIn({
    required String username,
    required String password,
  }) async {
    try {
      await pocketBase
          .collection(authCollectionName.authCollectionName)
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
