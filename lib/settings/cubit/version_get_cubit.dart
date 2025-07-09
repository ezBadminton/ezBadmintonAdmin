import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pocketbase/pocketbase.dart';

part 'version_get_state.dart';

class VersionGetCubit extends Cubit<VersionGetState> {
  VersionGetCubit({
    required this.pocketBase,
  }) : super(VersionGetState()) {
    const String clientVersion =
        String.fromEnvironment("VERSION", defaultValue: "dev");
    emit(state.copyWith(clientVersion: clientVersion));
    _fetchServerVersion();
  }

  final PocketBase pocketBase;

  static const String _path = "/api/version";

  void _fetchServerVersion() async {
    final dynamic serverVersion;
    try {
      serverVersion = await pocketBase.send(_path);
    } catch (_) {
      return;
    }

    emit(state.copyWith(serverVersion: serverVersion));
  }
}
