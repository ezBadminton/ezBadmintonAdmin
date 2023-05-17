import 'package:pocketbase/pocketbase.dart';

class PocketBaseProvider {
  final PocketBase pocketBase;
  // This Future resolves when the PocketBase server has been reached
  late Future<void> whenAvailable;

  PocketBaseProvider([String pocketbaseUrl = 'http://127.0.0.1:8090'])
      : pocketBase = PocketBase(pocketbaseUrl) {
    whenAvailable = _waitForAvailability();
  }

  Future<void> _waitForAvailability() async {
    while (!(await _isAvailable())) {}
    return;
  }

  Future<bool> _isAvailable() async {
    try {
      await pocketBase.health.check();
      return true;
    } on ClientException {
      return false;
    }
  }
}
