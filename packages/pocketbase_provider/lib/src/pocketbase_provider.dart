import 'package:pocketbase/pocketbase.dart';

class PocketBaseProvider {
  static final PocketBaseProvider _singleton = PocketBaseProvider._internal();
  final PocketBase pocketBase = PocketBase('http://127.0.0.1:8090');
  // This Future resolves when the PocketBase server has been reached
  late Future<void> whenAvailable;

  PocketBaseProvider._internal() {
    whenAvailable = _waitForAvailability();
  }

  factory PocketBaseProvider() {
    return _singleton;
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
