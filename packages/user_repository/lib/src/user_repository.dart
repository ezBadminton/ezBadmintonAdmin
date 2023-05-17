import 'dart:async';
import 'package:pocketbase_provider/pocketbase_provider.dart';
import 'package:user_repository/src/models/models.dart';

class UserRepository {
  UserRepository({required PocketBaseProvider pocketBaseProvider})
      : _pocketBaseProvider = pocketBaseProvider,
        _pocketBase = pocketBaseProvider.pocketBase;

  final _pocketBaseProvider;
  final _pocketBase;
  User? _user;

  Future<User?> getUser() async {
    if (_pocketBase.authStore.isValid) {
      if (_user != null) return _user;
      return _user = User(_pocketBase.authStore.model.id);
    }
    return _user = null;
  }
}
