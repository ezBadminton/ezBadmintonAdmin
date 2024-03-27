import 'package:collection/collection.dart';
import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/collection_queries/collection_querier.dart';
import 'package:ez_badminton_admin_app/competition_management/utils/competition_queries.dart';
import 'package:ez_badminton_admin_app/utils/list_extension/list_extension.dart';
import 'package:ez_badminton_admin_app/utils/sorting.dart';
import 'package:ez_badminton_admin_app/input_models/models.dart';
import 'package:ez_badminton_admin_app/widgets/dialog_listener/cubit_mixin/dialog_cubit.dart';
import 'package:ez_badminton_admin_app/widgets/loading_screen/loading_screen.dart';
import 'package:flutter/material.dart';
import 'package:formz/formz.dart';

part 'playing_level_editing_state.dart';

class PlayingLevelEditingCubit
    extends CollectionQuerierCubit<PlayingLevelEditingState>
    with
        DialogCubit<PlayingLevelEditingState>,
        RemovedCategoryCompetitionManagement<PlayingLevelEditingState> {
  PlayingLevelEditingCubit({
    required CollectionRepository<PlayingLevel> playingLevelRepository,
    required CollectionRepository<Competition> competitionRepository,
    required CollectionRepository<Team> teamRepository,
  }) : super(
          collectionRepositories: [
            playingLevelRepository,
            competitionRepository,
            teamRepository,
          ],
          PlayingLevelEditingState(),
        );

  final FocusNode focusNode = FocusNode();
  final TextEditingController controller = TextEditingController();

  @override
  void onCollectionUpdate(
    List<List<Model>> collections,
    List<CollectionUpdateEvent<Model>> updateEvents,
  ) {
    PlayingLevelEditingState updatedState = state.copyWith(
      collections: collections,
      loadingStatus: LoadingStatus.done,
      renamingPlayingLevel: const SelectionInput.pure(),
      playingLevelRename: const NonEmptyInput.pure(),
    );

    List<PlayingLevel> sortedPlayingLevels =
        updatedState.getCollection<PlayingLevel>().sorted(comparePlayingLevels);
    updatedState.overrideCollection(sortedPlayingLevels);

    updatedState = updatedState.copyWith(
      displayPlayingLevels: updatedState.getCollection<PlayingLevel>(),
    );

    _emit(updatedState);
  }

  void playingLevelNameChanged(String playingLevelName) {
    _emit(state.copyWith(
      playingLevelName: NonEmptyInput.dirty(value: playingLevelName),
    ));
  }

  void playingLevelSubmitted() {
    if (!state.formSubmittable) {
      return;
    }

    PlayingLevel newPlayingLevel = PlayingLevel.newPlayingLevel(
      state.playingLevelName.value,
      state.getCollection<PlayingLevel>().length,
    );

    _addPlayingLevel(newPlayingLevel);
  }

  void playingLevelRemoved(PlayingLevel removedPlayingLevel) async {
    assert(
      removedPlayingLevel.id.isNotEmpty,
      'Given PlayingLevel does not exist on DB',
    );
    if (state.formStatus == FormzSubmissionStatus.inProgress) {
      return;
    }
    _emit(state.copyWith(formStatus: FormzSubmissionStatus.inProgress));

    (FormzSubmissionStatus, Model?) replacementConfirmation =
        await askForReplacementCategory(removedPlayingLevel);
    FormzSubmissionStatus confirmation = replacementConfirmation.$1;
    Model? replacementCateogry = replacementConfirmation.$2;

    if (confirmation != FormzSubmissionStatus.success) {
      _emit(state.copyWith(formStatus: confirmation));
      return;
    }

    Map<String, dynamic> query = {};
    if (replacementCateogry != null) {
      query["replacement"] = replacementCateogry.id;
    }

    bool playingLevelDeleted = await querier.deleteModel(
      removedPlayingLevel,
      query: query,
    );
    if (isClosed) {
      return;
    }
    if (!playingLevelDeleted) {
      _emit(state.copyWith(formStatus: FormzSubmissionStatus.failure));
      return;
    }

    List<PlayingLevel> reorderedPlayingLevels = _syncPlayingLevelIndices(
      state.displayPlayingLevels,
      removedPlayingLevel: removedPlayingLevel,
    );

    bool indicesUpdated = await _updateReorderedPlayingLevels(
      reorderedPlayingLevels,
    );
    if (isClosed) {
      return;
    }
    if (!indicesUpdated) {
      _emit(state.copyWith(formStatus: FormzSubmissionStatus.failure));
      return;
    }

    _emit(state.copyWith(formStatus: FormzSubmissionStatus.success));
  }

  void _addPlayingLevel(PlayingLevel newPlayingLevel) async {
    if (state.formStatus == FormzSubmissionStatus.inProgress) {
      return;
    }
    _emit(state.copyWith(formStatus: FormzSubmissionStatus.inProgress));

    PlayingLevel? newPlayingLevelFromDB =
        await querier.createModel(newPlayingLevel);

    if (isClosed) {
      return;
    }
    if (newPlayingLevelFromDB == null) {
      _emit(state.copyWith(formStatus: FormzSubmissionStatus.failure));
      return;
    }

    _emit(state.copyWith(formStatus: FormzSubmissionStatus.success));

    controller.text = '';
    focusNode.requestFocus();
  }

  void playingLevelsReordered(int from, int to) async {
    if (state.formStatus == FormzSubmissionStatus.inProgress) {
      return;
    }
    // Update order of display PlayingLevels
    List<PlayingLevel> currentPlayingLevels = state.displayPlayingLevels;

    List<PlayingLevel> reorderedPlayingLevels =
        currentPlayingLevels.moveItem(from, to);

    reorderedPlayingLevels = _syncPlayingLevelIndices(reorderedPlayingLevels);

    _emit(state.copyWith(
      formStatus: FormzSubmissionStatus.inProgress,
      displayPlayingLevels: reorderedPlayingLevels,
    ));

    bool indicesUpdated = await _updateReorderedPlayingLevels(
      reorderedPlayingLevels,
    );
    if (isClosed) {
      return;
    }
    if (!indicesUpdated) {
      _emit(state.copyWith(formStatus: FormzSubmissionStatus.failure));
      return;
    }

    _emit(state.copyWith(formStatus: FormzSubmissionStatus.success));
  }

  /// Returns a copy of [reorderedPlayingLevels] with the [PlayingLevel]s
  /// inside having their `index` members synced to their index in the list.
  ///
  /// If the indices have to shift because a PlayingLevel was removed, pass the
  /// [removedPlayingLevel]. It will also be removed from the copy.
  List<PlayingLevel> _syncPlayingLevelIndices(
    List<PlayingLevel> reorderedPlayingLevels, {
    PlayingLevel? removedPlayingLevel,
  }) {
    List<PlayingLevel> updatedPlayingLevels = List.of(reorderedPlayingLevels);

    if (removedPlayingLevel != null) {
      updatedPlayingLevels.remove(removedPlayingLevel);
    }

    for (int i = 0; i < updatedPlayingLevels.length; i += 1) {
      if (updatedPlayingLevels[i].index != i) {
        PlayingLevel reorderedPlayingLevel =
            updatedPlayingLevels[i].copyWith(index: i);
        updatedPlayingLevels[i] = reorderedPlayingLevel;
      }
    }

    return updatedPlayingLevels;
  }

  /// Finds [PlayingLevel]s where the `index` was changed in
  /// [reorderedPlayingLevels] and updates those on the DB.
  Future<bool> _updateReorderedPlayingLevels(
    List<PlayingLevel> reorderedPlayingLevels,
  ) async {
    List<PlayingLevel> changedPlayingLevels = reorderedPlayingLevels
        .where((playingLevel) =>
            state
                .getCollection<PlayingLevel>()
                .firstWhere((lvl) => lvl.id == playingLevel.id)
                .index !=
            playingLevel.index)
        .toList();

    List<PlayingLevel?> updatedPlayingLevels =
        await querier.updateModels(changedPlayingLevels);

    return !updatedPlayingLevels.contains(null);
  }

  void playingLevelRenameFormOpened(PlayingLevel playingLevel) {
    assert(state.renamingPlayingLevel.value == null);
    _emit(state.copyWith(
      renamingPlayingLevel: SelectionInput.dirty(value: playingLevel),
      playingLevelRename: NonEmptyInput.pure(value: playingLevel.name),
    ));
  }

  void playingLevelRenameFormClosed() {
    assert(state.renamingPlayingLevel.value != null);
    if (_doSubmitRename()) {
      _submitRename();
    } else {
      _emit(state.copyWith(
        renamingPlayingLevel: const SelectionInput.pure(),
        playingLevelRename: const NonEmptyInput.pure(),
      ));
    }
  }

  void playingLevelRenameChanged(String name) {
    assert(state.renamingPlayingLevel.value != null);
    _emit(state.copyWith(playingLevelRename: NonEmptyInput.dirty(value: name)));
  }

  void _submitRename() async {
    if (state.formStatus == FormzSubmissionStatus.inProgress) {
      return;
    }
    _emit(state.copyWith(formStatus: FormzSubmissionStatus.inProgress));

    PlayingLevel renamedPlayingLevel = state.renamingPlayingLevel.value!
        .copyWith(name: state.playingLevelRename.value);

    PlayingLevel? updatedPlayingLevel =
        await querier.updateModel(renamedPlayingLevel);

    if (isClosed) {
      return;
    }
    if (updatedPlayingLevel == null) {
      _emit(state.copyWith(formStatus: FormzSubmissionStatus.failure));
      return;
    }

    _emit(state.copyWith(formStatus: FormzSubmissionStatus.success));
  }

  bool _doSubmitRename() {
    if (state.playingLevelRename.isNotValid ||
        state.playingLevelRename.isPure) {
      return false;
    }

    Iterable<PlayingLevel> sameName = state.getCollection<PlayingLevel>().where(
          (lvl) =>
              lvl.name.toLowerCase() ==
              state.playingLevelRename.value.toLowerCase(),
        );
    if (sameName.isNotEmpty) {
      return false;
    }

    return true;
  }

  void _emit(PlayingLevelEditingState state) {
    bool isInteractable = _isFormInteractable(state);
    bool isSubmittable = _isFormSubmittable(state);

    emit(state.copyWith(
      formInteractable: isInteractable,
      formSubmittable: isSubmittable,
    ));
  }

  static bool _isFormInteractable(PlayingLevelEditingState state) {
    return state.loadingStatus == LoadingStatus.done &&
        state.formStatus != FormzSubmissionStatus.inProgress &&
        state.renamingPlayingLevel.value == null;
  }

  static bool _isFormSubmittable(PlayingLevelEditingState state) {
    if (!_isFormInteractable(state) || state.playingLevelName.isNotValid) {
      return false;
    }

    PlayingLevel? existingPlayingLevel = state
        .getCollection<PlayingLevel>()
        .where(
          (level) =>
              level.name.toLowerCase() ==
              state.playingLevelName.value.toLowerCase(),
        )
        .firstOrNull;

    return existingPlayingLevel == null;
  }
}
