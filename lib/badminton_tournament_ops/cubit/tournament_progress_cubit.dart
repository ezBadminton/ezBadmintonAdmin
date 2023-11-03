import 'package:collection/collection.dart';
import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/badminton_tournament_ops/badminton_match.dart';
import 'package:ez_badminton_admin_app/badminton_tournament_ops/badminton_tournament_modes.dart';
import 'package:ez_badminton_admin_app/badminton_tournament_ops/tournament_mode_hydration.dart';
import 'package:ez_badminton_admin_app/collection_queries/collection_querier.dart';
import 'package:ez_badminton_admin_app/competition_management/utils/sorting.dart';
import 'package:ez_badminton_admin_app/widgets/loading_screen/loading_screen.dart';

part 'tournament_progress_state.dart';

class TournamentProgressCubit
    extends CollectionFetcherCubit<TournamentProgressState> {
  TournamentProgressCubit({
    required CollectionRepository<Competition> competitionRepository,
    required CollectionRepository<Court> courtRepository,
  }) : super(
          collectionRepositories: [
            competitionRepository,
            courtRepository,
          ],
          TournamentProgressState(),
        ) {
    loadCollections();
    subscribeToCollectionUpdates(
      competitionRepository,
      (_) => loadCollections(),
    );
    subscribeToCollectionUpdates(
      courtRepository,
      (_) => loadCollections(),
    );
  }

  void loadCollections() {
    if (state.loadingStatus != LoadingStatus.loading) {
      emit(state.copyWith(loadingStatus: LoadingStatus.loading));
    }
    fetchCollectionsAndUpdateState(
      [
        collectionFetcher<Competition>(),
        collectionFetcher<Court>(),
      ],
      onSuccess: (updatedState) {
        updatedState = updatedState.copyWithCourtSorting();
        updatedState = _createRunningTournamentState(updatedState);
        emit(updatedState.copyWith(loadingStatus: LoadingStatus.done));
      },
      onFailure: () {
        emit(state.copyWith(loadingStatus: LoadingStatus.failed));
      },
    );
  }

  TournamentProgressState _createRunningTournamentState(
    TournamentProgressState state,
  ) {
    List<Competition> runningCompetitions = state
        .getCollection<Competition>()
        .where((c) => c.matches.isNotEmpty)
        .toList();

    Map<Competition, BadmintonTournamentMode> runningTournaments = {
      for (Competition competition in runningCompetitions)
        competition: createTournamentMode(competition),
    };

    for (Competition competition in runningCompetitions) {
      BadmintonTournamentMode tournament = runningTournaments[competition]!;

      hydrateTournament(tournament, competition.matches);

      for (BadmintonMatch match in tournament.matches) {
        match.competition = competition;
      }
    }

    List<BadmintonMatch> runningMatches = runningTournaments.values
        .expand((t) => t.matches)
        .where((match) => match.court != null && match.endTime == null)
        .toList();

    Map<Court, BadmintonMatch> occupiedCourts = {
      for (BadmintonMatch match in runningMatches) match.court!: match,
    };

    List<Court> openCourts = state
        .getCollection<Court>()
        .whereNot((court) => occupiedCourts.keys.contains(court))
        .toList();

    Map<Player, BadmintonMatch> playingPlayers = {
      for (BadmintonMatch match in runningMatches)
        for (Player player in match.getPlayersOfMatch()) player: match,
    };

    List<BadmintonMatch> finishedMatches = runningTournaments.values
        .expand((t) => t.matches)
        .where((match) => match.isCompleted)
        .sortedBy((match) => match.endTime!)
        .toList();

    Map<Player, DateTime> restingPlayers = {
      for (BadmintonMatch match in finishedMatches)
        for (Player player in match.getPlayersOfMatch()) player: match.endTime!,
    };

    return state.copyWith(
      runningTournaments: runningTournaments,
      occupiedCourts: occupiedCourts,
      openCourts: openCourts,
      playingPlayers: playingPlayers,
      restingPlayers: restingPlayers,
    );
  }
}
