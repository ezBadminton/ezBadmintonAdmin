// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'version_get_cubit.dart';

class VersionGetState {
  VersionGetState({
    this.clientVersion = "",
    this.serverVersion = "unknown",
  });

  final String clientVersion;
  final String serverVersion;

  VersionGetState copyWith({
    String? clientVersion,
    String? serverVersion,
  }) {
    return VersionGetState(
      clientVersion: clientVersion ?? this.clientVersion,
      serverVersion: serverVersion ?? this.serverVersion,
    );
  }
}
