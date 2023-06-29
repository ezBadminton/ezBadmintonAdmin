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

    // Update order in the DB collection
    int index = 0;
    for (PlayingLevel playingLevel in reorderedPlayingLevels) {
      if (playingLevel.index != index) {
        PlayingLevel reorderedPlayingLevel =
            playingLevel.copyWith(index: index);
        PlayingLevel? updatedPlayingLevel =
            await querier.updateModel(reorderedPlayingLevel);
        if (updatedPlayingLevel == null) {
          emit(state.copyWith(
            formStatus: FormzSubmissionStatus.failure,
            displayPlayingLevels: state.getCollection<PlayingLevel>(),
          ));
          return;
        }
      }
      index += 1;
    }

    emit(state.copyWith(formStatus: FormzSubmissionStatus.success));
    loadPlayingLevels();
  }
}
