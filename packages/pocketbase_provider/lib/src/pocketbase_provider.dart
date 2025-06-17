import 'dart:async';

import 'package:pocketbase/pocketbase.dart';

class PocketBaseProvider {
  final PocketBase pocketBase;

  final StreamController<ConnectionEvent> _conntectivityStreamController;
  bool _isConnected = false;
  bool get isConnected => _isConnected;

  // This boradcast stream emits an event whenever the connection to the
  // PocketBase server is established or broken
  Stream<ConnectionEvent> get connectivitySteam =>
      _conntectivityStreamController.stream;

  Future<void> Function()? _pingUnsubscribe;

  PocketBaseProvider([String pocketbaseUrl = 'http://127.0.0.1:8090'])
      : pocketBase = PocketBase(pocketbaseUrl),
        _conntectivityStreamController = StreamController.broadcast() {
    pocketBase.realtime.subscribe("PB_CONNECT", _handleConnect);
    pocketBase.realtime.onDisconnect = _handleDisconnect;
  }

  void _handleConnect(e) async {
    if (_pingUnsubscribe != null) {
      _pingUnsubscribe!();
    }
    _pingUnsubscribe = await pocketBase.realtime.subscribe("ping", (e) {});
    _isConnected = true;
    _conntectivityStreamController.add(ConnectionEvent.connected);
  }

  void _handleDisconnect(Map _) {
    _isConnected = false;
    _conntectivityStreamController.add(ConnectionEvent.disconnected);
  }

  void reconnect() {
    _conntectivityStreamController.add(ConnectionEvent.disconnected);
    Future.delayed(
      const Duration(milliseconds: 100),
      () => _conntectivityStreamController.add(ConnectionEvent.connected),
    );
  }
}

enum ConnectionEvent {
  connected,
  disconnected,
}
