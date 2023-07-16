import 'package:collection/collection.dart';
import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/collection_queries/collection_querier.dart';
import 'package:ez_badminton_admin_app/competition_management/utils/sorting.dart';
import 'package:ez_badminton_admin_app/input_models/models.dart';
import 'package:ez_badminton_admin_app/widgets/loading_screen/loading_screen.dart';
import 'package:formz/formz.dart';

part 'playing_level_editing_state.dart';

class PlayingLevelEditingCubit
    extends CollectionFetcherCubit<PlayingLevelEditingState> {
  PlayingLevelEditingCubit({
    required CollectionRepository<PlayingLevel> playingLevelRepository,
    required CollectionRepository<Competition> competitionRepository,
  }) : super(
          collectionRepositories: [
            playingLevelRepository,
            competitionRepository,
          ],
          PlayingLevelEditingState(),
        ) {
    loadPlayingLevels();
  }

  void loadPlayingLevels() {
    if (state.loadingStatus != LoadingStatus.loading) {
      emit(state.copyWith(loadingStatus: LoadingStatus.loading));
    }
    fetchCollectionsAndUpdateState(
      [
        collectionFetcher<PlayingLevel>(),
        collectionFetcher<Competition>(),
      ],
      onSuccess: (updatedState) {
        updatedState = updatedState.copyWithPlayingLevelSorting();

        updatedState = updatedState.copyWith(
          loadingStatus: LoadingStatus.done,
          displayPlayingLevels: updatedState.getCollection<PlayingLevel>(),
          renamingPlayingLevel: const SelectionInput.pure(),
          playingLevelRename: const NonEmptyInput.pure(),
        );

        emit(updatedState);
      },
      onFailure: () {
        emit(state.copyWith(loadingStatus: LoadingStatus.failed));
      },
    );
  }

  void playingLevelNameChanged(String playingLevelName) {
    emit(state.copyWith(
      playingLevelName: NonEmptyInput.dirty(playingLevelName),
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
    emit(state.copyWith(formStatus: FormzSubmissionStatus.inProgress));

    Iterable<Competition> competitionsUsingPlayingLevel = state
        .getCollection<Competition>()
        .where((c) => c.playingLevel == removedPlayingLevel);
    if (competitionsUsingPlayingLevel.isNotEmpty) {
      // Don't delete playing levels that are used
      emit(state.copyWith(formStatus: FormzSubmissionStatus.failure));
      return;
    }

    bool playingLevelDeleted = await querier.deleteModel(removedPlayingLevel);
    if (isClosed) {
      return;
    }
    if (!playingLevelDeleted) {
      emit(state.copyWith(formStatus: FormzSubmissionStatus.failure));
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
      emit(state.copyWith(formStatus: FormzSubmissionStatus.failure));
      return;
    }

    emit(state.copyWith(formStatus: FormzSubmissionStatus.success));
    loadPlayingLevels();
  }

  void _addPlayingLevel(PlayingLevel newPlayingLevel) async {
    if (state.formStatus == FormzSubmissionStatus.inProgress) {
      return;
    }
    emit(state.copyWith(formStatus: FormzSubmissionStatus.inProgress));

    PlayingLevel? newPlayingLevelFromDB =
        await querier.createModel(newPlayingLevel);

    if (isClosed) {
      return;
    }
    if (newPlayingLevelFromDB == null) {
      emit(state.copyWith(formStatus: FormzSubmissionStatus.failure));
      return;
    }

    emit(state.copyWith(formStatus: FormzSubmissionStatus.success));
    loadPlayingLevels();
  }

  void playingLevelsReordered(int from, int to) async {
    if (state.formStatus == FormzSubmissionStatus.inProgress) {
      return;
    }
    // Update order of display PlayingLevels
    List<PlayingLevel> currentPlayingLevels = state.displayPlayingLevels;
    PlayingLevel reordered = currentPlayingLevels[from];
    if (to > from) {
      to += 1;
    }
    List<PlayingLevel> reorderedPlayingLevels = List.of(currentPlayingLevels)
      ..insert(to, reordered);
    if (to < from) {
      from += 1;
    }
    reorderedPlayingLevels.removeAt(from);

    reorderedPlayingLevels = _syncPlayingLevelIndices(reorderedPlayingLevels);

    emit(state.copyWith(
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
      emit(state.copyWith(formStatus: FormzSubmissionStatus.failure));
      return;
    }

    emit(state.copyWith(formStatus: FormzSubmissionStatus.success));
    loadPlayingLevels();
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

  /// Finds [PlayingLevels] where the `index` was changed in
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

    Iterable<Future<PlayingLevel?>> playingLevelUpdates =
        changedPlayingLevels.map((lvl) => querier.updateModel(lvl));
    List<PlayingLevel?> updatedPlayingLevels =
        await Future.wait(playingLevelUpdates);

    return !updatedPlayingLevels.contains(null);
  }

  void playingLevelRenameFormOpened(PlayingLevel playingLevel) {
    assert(state.renamingPlayingLevel.value == null);
    emit(state.copyWith(
      renamingPlayingLevel: SelectionInput.dirty(value: playingLevel),
      playingLevelRename: NonEmptyInput.pure(playingLevel.name),
    ));
  }

  void playingLevelRenameFormClosed() {
    assert(state.renamingPlayingLevel.value != null);
    if (_doSubmitRename()) {
      _submitRename();
    } else {
      emit(state.copyWith(
        renamingPlayingLevel: const SelectionInput.pure(),
        playingLevelRename: const NonEmptyInput.pure(),
      ));
    }
  }

  void playingLevelRenameChanged(String name) {
    assert(state.renamingPlayingLevel.value != null);
    emit(state.copyWith(playingLevelRename: NonEmptyInput.dirty(name)));
  }

  void _submitRename() async {
    if (state.formStatus == FormzSubmissionStatus.inProgress) {
      return;
    }
    emit(state.copyWith(formStatus: FormzSubmissionStatus.inProgress));

    PlayingLevel renamedPlayingLevel = state.renamingPlayingLevel.value!
        .copyWith(name: state.playingLevelRename.value);

    PlayingLevel? updatedPlayingLevel =
        await querier.updateModel(renamedPlayingLevel);

    if (isClosed) {
      return;
    }
    if (updatedPlayingLevel == null) {
      emit(state.copyWith(formStatus: FormzSubmissionStatus.failure));
      return;
    }

    emit(state.copyWith(formStatus: FormzSubmissionStatus.success));
    loadPlayingLevels();
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
}
