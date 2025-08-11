// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'local_preferences_cubit.dart';

class LocalPreferencesState {
  const LocalPreferencesState({
    this.queueMode = QueueMode.manual,
    this.showGlobalCompetitionFilterNotification = true,
  });

  final QueueMode queueMode;

  final bool showGlobalCompetitionFilterNotification;

  LocalPreferencesState copyWith({
    QueueMode? queueMode,
    bool? showGlobalCompetitionFilterNotification,
  }) {
    return LocalPreferencesState(
      queueMode: queueMode ?? this.queueMode,
      showGlobalCompetitionFilterNotification:
          showGlobalCompetitionFilterNotification ??
              this.showGlobalCompetitionFilterNotification,
    );
  }
}
