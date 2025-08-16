// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'local_preferences_cubit.dart';

class LocalPreferencesState {
  const LocalPreferencesState({
    this.queueMode = QueueMode.manual,
    this.showGlobalCompetitionFilterNotification = true,
    this.showQualificationOverrideNotification = true,
  });

  final QueueMode queueMode;

  final bool showGlobalCompetitionFilterNotification;
  final bool showQualificationOverrideNotification;

  LocalPreferencesState copyWith({
    QueueMode? queueMode,
    bool? showGlobalCompetitionFilterNotification,
    bool? showQualificationOverrideNotification,
  }) {
    return LocalPreferencesState(
      queueMode: queueMode ?? this.queueMode,
      showGlobalCompetitionFilterNotification:
          showGlobalCompetitionFilterNotification ??
              this.showGlobalCompetitionFilterNotification,
      showQualificationOverrideNotification:
          showQualificationOverrideNotification ??
              this.showQualificationOverrideNotification,
    );
  }
}
