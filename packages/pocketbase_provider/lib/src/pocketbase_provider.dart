import 'dart:async';

import 'package:pocketbase/pocketbase.dart';

class PocketBaseProvider {
  final PocketBase pocketBase;

  final StreamController<ConnectionEvent> _conntectivityStreamController;
  bool _isConnected = false;

  // This boradcast stream emits an event whenever the connection to the
  // PocketBase server is established or broken
  Stream<ConnectionEvent> get connectivitySteam =>
      _conntectivityStreamController.stream;

  PocketBaseProvider([String pocketbaseUrl = 'http://127.0.0.1:8090'])
      : pocketBase = PocketBase(pocketbaseUrl),
        _conntectivityStreamController = StreamController.broadcast() {
    _waitForConnection();
  }

  Future<void> _waitForConnection() async {
    while (!_isConnected) {
      await _checkConnection();
    }
    return;
  }

  Future<void> _checkConnection() async {
    try {
      await pocketBase.health.check();
      _isConnected = true;
      _conntectivityStreamController.add(ConnectionEvent.connected);
    } on ClientException {
      return;
    }
  }
}

enum ConnectionEvent {
  connected,
  disconnected,
}
