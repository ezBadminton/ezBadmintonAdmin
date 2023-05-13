import 'dart:async';
import 'package:pocketbase_provider/pocketbase_provider.dart';
import 'package:user_repository/src/models/models.dart';

class UserRepository {
  final pocketBase = PocketBaseProvider().pocketBase;
  User? _user;

  Future<User?> getUser() async {
    if (pocketBase.authStore.isValid) {
      if (_user != null) return _user;
      return _user = User(pocketBase.authStore.model.id);
    }
    return _user = null;
  }
}
