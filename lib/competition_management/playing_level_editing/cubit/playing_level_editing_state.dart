part of 'playing_level_editing_cubit.dart';

class PlayingLevelEditingState
    extends CollectionFetcherState<PlayingLevelEditingState> {
  PlayingLevelEditingState({
    this.playingLevelName = const NonEmptyInput.pure(),
    this.displayPlayingLevels = const [],
    this.loadingStatus = LoadingStatus.loading,
    this.formStatus = FormzSubmissionStatus.initial,
    this.renamingPlayingLevel = const SelectionInput.dirty(),
    this.playingLevelRename = const NonEmptyInput.pure(),
    super.collections = const {},
  })  : formInteractable = _isFormInteractable(
          loadingStatus,
          formStatus,
          renamingPlayingLevel.value,
        ),
        formSubmittable = _isFormSubmittable(
          loadingStatus,
          formStatus,
          renamingPlayingLevel.value,
          playingLevelName,
          (collections[PlayingLevel] as List<PlayingLevel>?) ?? [],
        );

  final NonEmptyInput playingLevelName;

  // Separate PlayingLevels for display to be able to instantly change the order
  // before the collection has actually updated
  final List<PlayingLevel> displayPlayingLevels;

  final LoadingStatus loadingStatus;
  final FormzSubmissionStatus formStatus;

  final bool formInteractable;
  final bool formSubmittable;

  final SelectionInput<PlayingLevel> renamingPlayingLevel;
  final NonEmptyInput playingLevelRename;

  PlayingLevelEditingState copyWith({
    NonEmptyInput? playingLevelName,
    List<PlayingLevel>? displayPlayingLevels,
    LoadingStatus? loadingStatus,
    FormzSubmissionStatus? formStatus,
    SelectionInput<PlayingLevel>? renamingPlayingLevel,
    NonEmptyInput? playingLevelRename,
    Map<Type, List<Model>>? collections,
  }) =>
      PlayingLevelEditingState(
        playingLevelName: playingLevelName ?? this.playingLevelName,
        displayPlayingLevels: displayPlayingLevels ?? this.displayPlayingLevels,
        loadingStatus: loadingStatus ?? this.loadingStatus,
        formStatus: formStatus ?? this.formStatus,
        renamingPlayingLevel: renamingPlayingLevel ?? this.renamingPlayingLevel,
        playingLevelRename: playingLevelRename ?? this.playingLevelRename,
        collections: collections ?? this.collections,
      );

  static bool _isFormInteractable(
    LoadingStatus loadingStatus,
    FormzSubmissionStatus formStatus,
    PlayingLevel? renamingPlayingLevel,
  ) {
    return loadingStatus == LoadingStatus.done &&
        formStatus != FormzSubmissionStatus.inProgress &&
        renamingPlayingLevel == null;
  }

  static bool _isFormSubmittable(
    LoadingStatus loadingStatus,
    FormzSubmissionStatus formStatus,
    PlayingLevel? renamingPlayingLevel,
    NonEmptyInput playingLevelName,
    List<PlayingLevel> playingLevelCollection,
  ) {
    if (!_isFormInteractable(loadingStatus, formStatus, renamingPlayingLevel) ||
        playingLevelName.isNotValid) {
      return false;
    }

    PlayingLevel? existingPlayingLevel = playingLevelCollection
        .where(
          (level) =>
              level.name.toLowerCase() == playingLevelName.value.toLowerCase(),
        )
        .firstOrNull;

    return existingPlayingLevel == null;
  }
}
