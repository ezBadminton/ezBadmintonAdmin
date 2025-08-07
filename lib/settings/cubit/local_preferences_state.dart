// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'local_preferences_cubit.dart';

class LocalPreferencesState {
  const LocalPreferencesState({
    this.queueMode = QueueMode.manual,
  });

  final QueueMode queueMode;

  LocalPreferencesState copyWith({
    QueueMode? queueMode,
  }) {
    return LocalPreferencesState(
      queueMode: queueMode ?? this.queueMode,
    );
  }
}
