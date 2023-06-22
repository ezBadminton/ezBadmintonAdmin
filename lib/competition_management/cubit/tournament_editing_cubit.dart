import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/collection_queries/collection_querier.dart';
import 'package:ez_badminton_admin_app/competition_management/cubit/tournament_editing_state.dart';
import 'package:ez_badminton_admin_app/widgets/loading_screen/loading_screen.dart';
import 'package:formz/formz.dart';

class TournamentEditingCubit
    extends CollectionFetcherCubit<TournamentEditingState> {
  TournamentEditingCubit({
    required CollectionRepository<Tournament> tournamentRepository,
  }) : super(
          collectionRepositories: [tournamentRepository],
          TournamentEditingState(),
        ) {
    loadTournamentCollection();
  }

  void loadTournamentCollection() {
    if (state.loadingStatus != LoadingStatus.loading) {
      emit(state.copyWith(loadingStatus: LoadingStatus.loading));
    }
    fetchCollectionsAndUpdateState(
      [
        collectionFetcher<Tournament>(),
      ],
      onSuccess: (updatedState) {
        emit(updatedState.copyWith(loadingStatus: LoadingStatus.done));
      },
      onFailure: () {
        emit(state.copyWith(loadingStatus: LoadingStatus.failed));
      },
    );
  }

  void useAgeGroupsChanged(bool useAgeGroups) {
    Tournament updatedTournament = state.tournament!.copyWith(
      useAgeGroups: useAgeGroups,
    );
    _updateTournament(updatedTournament);
  }

  void usePlayingLevelsChanged(bool usePlayingLevels) {
    Tournament updatedTournament = state.tournament!.copyWith(
      usePlayingLevels: usePlayingLevels,
    );
    _updateTournament(updatedTournament);
  }

  void _updateTournament(Tournament updatedTournament) async {
    if (state.formStatus == FormzSubmissionStatus.inProgress) {
      return;
    }
    emit(state.copyWith(formStatus: FormzSubmissionStatus.inProgress));
    Tournament? updatedTournamentFromDB =
        await querier.updateModel(updatedTournament);
    if (updatedTournamentFromDB == null) {
      emit(state.copyWith(formStatus: FormzSubmissionStatus.failure));
      return;
    }
    TournamentEditingState updatedState = state.copyWithCollection(
      modelType: Tournament,
      collection: [updatedTournamentFromDB],
    );
    emit(updatedState.copyWith(
      formStatus: FormzSubmissionStatus.success,
    ));
  }
}
