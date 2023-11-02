part of 'match_queue_settings_cubit.dart';

class MatchQueueSettingsState
    extends CollectionFetcherState<MatchQueueSettingsState> {
  MatchQueueSettingsState({
    this.loadingStatus = LoadingStatus.loading,
    this.formStatus = FormzSubmissionStatus.initial,
    super.collections = const {},
  });

  final LoadingStatus loadingStatus;
  final FormzSubmissionStatus formStatus;

  Tournament get tournament => getCollection<Tournament>().first;

  /// The minimum break time that a player has between their matches in minutes.
  int get playerRestTime => getCollection<Tournament>().first.playerRestTime;

  /// The mode that the match queuing follows. See [QueueMode].
  QueueMode get queueMode => getCollection<Tournament>().first.queueMode;

  MatchQueueSettingsState copyWith({
    LoadingStatus? loadingStatus,
    FormzSubmissionStatus? formStatus,
    Map<Type, List<Model>>? collections,
  }) {
    return MatchQueueSettingsState(
      loadingStatus: loadingStatus ?? this.loadingStatus,
      formStatus: formStatus ?? this.formStatus,
      collections: collections ?? this.collections,
    );
  }
}
