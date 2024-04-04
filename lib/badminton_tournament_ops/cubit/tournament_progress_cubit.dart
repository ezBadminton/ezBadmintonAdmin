import 'package:collection/collection.dart';
import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/badminton_tournament_ops/badminton_match.dart';
import 'package:ez_badminton_admin_app/badminton_tournament_ops/badminton_tournament_modes.dart';
import 'package:ez_badminton_admin_app/badminton_tournament_ops/tournament_mode_hydration.dart';
import 'package:ez_badminton_admin_app/collection_queries/collection_querier.dart';
import 'package:ez_badminton_admin_app/match_management/cubit/mixins/match_canceling_mixin.dart';
import 'package:ez_badminton_admin_app/utils/sorting.dart';
import 'package:ez_badminton_admin_app/widgets/loading_screen/loading_screen.dart';

part 'tournament_progress_state.dart';

class TournamentProgressCubit
    extends CollectionQuerierCubit<TournamentProgressState>
    with MatchCancelingMixin {
  TournamentProgressCubit({
    required CollectionRepository<Competition> competitionRepository,
    required CollectionRepository<Court> courtRepository,
    required CollectionRepository<MatchData> matchDataRepository,
  }) : super(
          collectionRepositories: [
            competitionRepository,
            courtRepository,
            matchDataRepository,
          ],
          TournamentProgressState(),
        );

  @override
  void onCollectionUpdate(
    List<List<Model>> collections,
    List<CollectionUpdateEvent<Model>> updateEvents,
  ) {
    TournamentProgressState updatedState = state.copyWith(
      collections: collections,
      loadingStatus: LoadingStatus.done,
    );

    List<Court> sortedCourts =
        updatedState.getCollection<Court>().sorted(compareCourts);
    updatedState.overrideCollection(sortedCourts);

    updatedState = _createRunningTournamentState(updatedState);

    emit(updatedState);
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

      hydrateTournament(competition, tournament, competition.matches);
    }

    List<BadmintonMatch> danglingMatches = runningTournaments.values
        .expand((tournament) => tournament.matches)
        .where((match) => match.isDangling)
        .toList();

    if (danglingMatches.isNotEmpty) {
      _cancelDanglingMatches(danglingMatches);
      return this.state;
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
        .where((match) => match.hasWinner && match.endTime != null)
        .sortedBy((match) => match.endTime!)
        .toList();

    Map<Player, DateTime> lastPlayerMatches = {
      for (BadmintonMatch match in finishedMatches)
        for (Player player in match.getPlayersOfMatch()) player: match.endTime!,
    };

    List<BadmintonMatch> editableMatches = runningTournaments.values
        .expand((tournament) => tournament.getEditableMatches())
        .toList();

    return state.copyWith(
      runningTournaments: runningTournaments,
      occupiedCourts: occupiedCourts,
      openCourts: openCourts,
      playingPlayers: playingPlayers,
      lastPlayerMatches: lastPlayerMatches,
      editableMatches: editableMatches,
    );
  }

  void _cancelDanglingMatches(List<BadmintonMatch> danglingMatches) {
    List<MatchData> canceledMatches = danglingMatches
        .map(
          (match) => cancelMatch(
            match.matchData!,
            state,
            unassignCourt: true,
          ),
        )
        .toList();

    querier.updateModels(canceledMatches);
  }
}
