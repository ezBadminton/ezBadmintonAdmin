import 'package:collection/collection.dart';
import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/badminton_tournament_ops/badminton_match.dart';
import 'package:ez_badminton_admin_app/badminton_tournament_ops/badminton_tournament_modes.dart';
import 'package:ez_badminton_admin_app/badminton_tournament_ops/tournament_mode_hydration.dart';
import 'package:ez_badminton_admin_app/collection_queries/collection_querier.dart';
import 'package:ez_badminton_admin_app/match_management/cubit/mixins/match_canceling_mixin.dart';
import 'package:ez_badminton_admin_app/utils/sorting.dart';
import 'package:ez_badminton_admin_app/widgets/loading_screen/loading_screen.dart';
import 'package:flutter/foundation.dart';

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

    updatedState = _createProgressState(updatedState, updateEvents);

    emit(updatedState);
  }

  TournamentProgressState _createProgressState(
    TournamentProgressState state,
    List<CollectionUpdateEvent<Model>> updateEvents,
  ) {
    bool updateTournaments = updateEvents.isEmpty ||
        updateEvents.firstWhereOrNull(
              (e) => e is CollectionUpdateEvent<Competition>,
            ) !=
            null;

    TournamentProgressState newState = state;

    if (updateTournaments) {
      newState = _updateRunningTournaments(newState);
    }

    newState = _updateProgressInfo(newState);

    return newState;
  }

  TournamentProgressState _updateProgressInfo(
    TournamentProgressState state,
  ) {
    List<BadmintonMatch> runningMatches = state.runningTournaments.values
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

    List<BadmintonMatch> finishedMatches = state.runningTournaments.values
        .expand((t) => t.matches)
        .where((match) => match.hasWinner && match.endTime != null)
        .sortedBy((match) => match.endTime!)
        .toList();

    Map<Player, DateTime> lastPlayerMatches = {
      for (BadmintonMatch match in finishedMatches)
        for (Player player in match.getPlayersOfMatch()) player: match.endTime!,
    };

    List<BadmintonMatch> editableMatches = state.runningTournaments.values
        .expand((tournament) => tournament.getEditableMatches())
        .toList();

    return state.copyWith(
      occupiedCourts: occupiedCourts,
      openCourts: openCourts,
      playingPlayers: playingPlayers,
      lastPlayerMatches: lastPlayerMatches,
      editableMatches: editableMatches,
    );
  }

  TournamentProgressState _updateRunningTournaments(
    TournamentProgressState state,
  ) {
    List<Competition> runningCompetitions = state
        .getCollection<Competition>()
        .where((c) => c.matches.isNotEmpty)
        .toList();

    List<(Competition, BadmintonTournamentMode)> updatingTournaments = [];
    List<Competition> creatingTournaments = [];

    for (Competition competition in runningCompetitions) {
      MapEntry<Competition, BadmintonTournamentMode>? oldTournamentEntry = this
          .state
          .runningTournaments
          .entries
          .firstWhereOrNull((entry) => entry.key == competition);

      if (oldTournamentEntry == null) {
        creatingTournaments.add(competition);
        continue;
      }

      Competition oldCompetition = oldTournamentEntry.key;
      BadmintonTournamentMode oldTournament = oldTournamentEntry.value;

      bool doRecreate = _doRecreateTournament(competition, oldCompetition);

      if (doRecreate) {
        creatingTournaments.add(competition);
      } else {
        oldTournament.competition = competition;
        updatingTournaments.add((competition, oldTournament));
      }
    }

    Map<Competition, BadmintonTournamentMode> runningTournaments = {
      for (Competition competition in creatingTournaments)
        competition: createTournamentMode(competition),
      for ((Competition, BadmintonTournamentMode) updatingTournament
          in updatingTournaments)
        updatingTournament.$1: updatingTournament.$2,
    };

    for (Competition competition in runningCompetitions) {
      bool isNew = creatingTournaments.contains(competition);
      BadmintonTournamentMode tournament = runningTournaments[competition]!;

      hydrateTournament(competition, tournament, competition.matches);

      tournament.updateTournament(forceCompleteUpdate: isNew);
    }

    List<BadmintonMatch> danglingMatches = runningTournaments.values
        .expand((tournament) => tournament.matches)
        .where((match) => !match.isPlayable && match.court != null)
        .toList();

    if (danglingMatches.isNotEmpty) {
      _cancelDanglingMatches(danglingMatches);
    }

    return state.copyWith(runningTournaments: runningTournaments);
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

  bool _doRecreateTournament(
    Competition competition,
    Competition oldCompetition,
  ) {
    bool doRecreate = (competition.tournamentModeSettings !=
            oldCompetition.tournamentModeSettings) ||
        !listEquals(competition.draw, oldCompetition.draw) ||
        !listEquals(competition.seeds, oldCompetition.seeds) ||
        !listEquals(competition.tieBreakers, oldCompetition.tieBreakers);

    return doRecreate;
  }
}
