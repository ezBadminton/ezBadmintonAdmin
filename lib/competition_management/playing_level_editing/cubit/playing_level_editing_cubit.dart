import 'package:collection/collection.dart';
import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/collection_queries/collection_querier.dart';
import 'package:ez_badminton_admin_app/input_models/no_validation.dart';
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
        List<PlayingLevel> playingLevels =
            List.of(updatedState.getCollection<PlayingLevel>());

        playingLevels.sortBy<num>((element) => element.index);
        updatedState = updatedState.copyWithCollection(
          modelType: PlayingLevel,
          collection: playingLevels,
        );

        emit(updatedState.copyWith(
          loadingStatus: LoadingStatus.done,
          displayPlayingLevels: updatedState.getCollection<PlayingLevel>(),
        ));
      },
      onFailure: () {
        emit(state.copyWith(loadingStatus: LoadingStatus.failed));
      },
    );
  }

  void playingLevelNameChanged(String playingLevelName) {
    emit(state.copyWith(
      playingLevelName: NoValidationInput.dirty(playingLevelName),
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
        .where((c) => c.playingLevels.contains(removedPlayingLevel));
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

    bool indicesUpdated = await _updatePlayingLevelIndices(
      removedPlayingLevel: removedPlayingLevel,
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
    List<PlayingLevel> currentPlayingLevels =
        state.getCollection<PlayingLevel>();
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

    emit(state.copyWith(
      formStatus: FormzSubmissionStatus.inProgress,
      displayPlayingLevels: reorderedPlayingLevels,
    ));

    bool indicesUpdated = await _updatePlayingLevelIndices();
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

  /// Apply the order of the displayPlayingLevels to the `index` member of each
  /// PlayingLevel and update it on DB.
  ///
  /// If the indices have to shift because a PlayingLevel was removed, pass the
  /// [removedPlayingLevel].
  Future<bool> _updatePlayingLevelIndices({
    PlayingLevel? removedPlayingLevel,
  }) async {
    int index = 0;
    for (PlayingLevel playingLevel in state.displayPlayingLevels) {
      if (playingLevel.index != index && playingLevel != removedPlayingLevel) {
        PlayingLevel reorderedPlayingLevel =
            playingLevel.copyWith(index: index);
        PlayingLevel? updatedPlayingLevel =
            await querier.updateModel(reorderedPlayingLevel);
        if (updatedPlayingLevel == null) {
          return false;
        }
      }
      if (playingLevel != removedPlayingLevel) {
        index += 1;
      }
    }
    return true;
  }
}
