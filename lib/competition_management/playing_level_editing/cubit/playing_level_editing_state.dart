part of 'playing_level_editing_cubit.dart';

class PlayingLevelEditingState
    extends CollectionFetcherState<PlayingLevelEditingState> {
  PlayingLevelEditingState({
    this.playingLevelName = const NoValidationInput.pure(),
    this.displayPlayingLevels = const [],
    this.loadingStatus = LoadingStatus.loading,
    this.formStatus = FormzSubmissionStatus.initial,
    super.collections = const {},
  }) : formInteractable = _isFormInteractable(loadingStatus, formStatus);

  final NoValidationInput playingLevelName;

  // Separate PlayingLevels for display to be able to instantly change the order
  // before the collection has actually updated
  final List<PlayingLevel> displayPlayingLevels;

  final LoadingStatus loadingStatus;
  final FormzSubmissionStatus formStatus;

  final bool formInteractable;

  PlayingLevelEditingState copyWith({
    NoValidationInput? playingLevelName,
    List<PlayingLevel>? displayPlayingLevels,
    LoadingStatus? loadingStatus,
    FormzSubmissionStatus? formStatus,
    Map<Type, List<Model>>? collections,
  }) =>
      PlayingLevelEditingState(
        playingLevelName: playingLevelName ?? this.playingLevelName,
        displayPlayingLevels: displayPlayingLevels ?? this.displayPlayingLevels,
        loadingStatus: loadingStatus ?? this.loadingStatus,
        formStatus: formStatus ?? this.formStatus,
        collections: collections ?? this.collections,
      );

  static bool _isFormInteractable(
    LoadingStatus loadingStatus,
    FormzSubmissionStatus formStatus,
  ) {
    return loadingStatus == LoadingStatus.done &&
        formStatus != FormzSubmissionStatus.inProgress;
  }
}
