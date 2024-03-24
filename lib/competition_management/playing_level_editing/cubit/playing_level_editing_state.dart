part of 'playing_level_editing_cubit.dart';

class PlayingLevelEditingState extends CollectionQuerierState
    implements DialogState {
  PlayingLevelEditingState({
    this.playingLevelName = const NonEmptyInput.pure(),
    this.displayPlayingLevels = const [],
    this.loadingStatus = LoadingStatus.loading,
    this.formStatus = FormzSubmissionStatus.initial,
    this.formInteractable = false,
    this.formSubmittable = false,
    this.renamingPlayingLevel = const SelectionInput.dirty(),
    this.playingLevelRename = const NonEmptyInput.pure(),
    this.dialog = const CubitDialog(),
    this.collections = const [],
  });

  final NonEmptyInput playingLevelName;

  // Separate PlayingLevels for display to be able to instantly change the order
  // before the collection has actually updated
  final List<PlayingLevel> displayPlayingLevels;

  @override
  final LoadingStatus loadingStatus;
  final FormzSubmissionStatus formStatus;

  final bool formInteractable;
  final bool formSubmittable;

  final SelectionInput<PlayingLevel> renamingPlayingLevel;
  final NonEmptyInput playingLevelRename;

  @override
  final CubitDialog dialog;

  @override
  final List<List<Model>> collections;

  PlayingLevelEditingState copyWith({
    NonEmptyInput? playingLevelName,
    List<PlayingLevel>? displayPlayingLevels,
    LoadingStatus? loadingStatus,
    FormzSubmissionStatus? formStatus,
    bool? formInteractable,
    bool? formSubmittable,
    SelectionInput<PlayingLevel>? renamingPlayingLevel,
    NonEmptyInput? playingLevelRename,
    CubitDialog? dialog,
    List<List<Model>>? collections,
  }) =>
      PlayingLevelEditingState(
        playingLevelName: playingLevelName ?? this.playingLevelName,
        displayPlayingLevels: displayPlayingLevels ?? this.displayPlayingLevels,
        loadingStatus: loadingStatus ?? this.loadingStatus,
        formStatus: formStatus ?? this.formStatus,
        formInteractable: formInteractable ?? this.formInteractable,
        formSubmittable: formSubmittable ?? this.formSubmittable,
        renamingPlayingLevel: renamingPlayingLevel ?? this.renamingPlayingLevel,
        playingLevelRename: playingLevelRename ?? this.playingLevelRename,
        dialog: dialog ?? this.dialog,
        collections: collections ?? this.collections,
      );
}
