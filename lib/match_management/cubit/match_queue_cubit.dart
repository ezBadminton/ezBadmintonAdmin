import 'dart:async';

import 'package:collection/collection.dart';
import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/badminton_tournament_ops/badminton_match.dart';
import 'package:ez_badminton_admin_app/badminton_tournament_ops/cubit/tournament_progress_cubit.dart';
import 'package:ez_badminton_admin_app/collection_queries/collection_querier.dart';
import 'package:ez_badminton_admin_app/match_management/cubit/mixins/match_court_assignment_query.dart';
import 'package:ez_badminton_admin_app/utils/sorting.dart';
import 'package:ez_badminton_admin_app/widgets/loading_screen/loading_screen.dart';

part 'match_queue_state.dart';

class MatchQueueCubit extends CollectionFetcherCubit<MatchQueueState>
    with MatchCourtAssignmentQuery {
  MatchQueueCubit({
    required CollectionRepository<Tournament> tournamentRepository,
    required CollectionRepository<MatchData> matchDataRepository,
  }) : super(
          collectionRepositories: [
            tournamentRepository,
            matchDataRepository,
          ],
          MatchQueueState(),
        ) {
    loadCollections();
    subscribeToCollectionUpdates(
      tournamentRepository,
      (_) => loadCollections(),
    );
  }

  Timer? _restTimer;

  void loadCollections() {
    if (state.loadingStatus != LoadingStatus.loading) {
      emit(state.copyWith(loadingStatus: LoadingStatus.loading));
    }
    fetchCollectionsAndUpdateState(
      [
        collectionFetcher<Tournament>(),
      ],
      onSuccess: (updatedState) {
        emit(updatedState.copyWith(loadingStatus: LoadingStatus.done));
        if (state.progressState != null) {
          tournamentChanged(state.progressState!);
        }
      },
      onFailure: () {
        emit(state.copyWith(loadingStatus: LoadingStatus.failed));
      },
    );
  }

  void tournamentChanged(TournamentProgressState progressState) {
    List<BadmintonMatch> matches = progressState.runningTournaments.values
        .expand((t) => t.matches)
        .where((match) => !match.isBye)
        .toList();

    Set<Player> playingPlayers = progressState.playingPlayers.keys.toSet();

    List<BadmintonMatch> playableMatches =
        matches.where((m) => m.isPlayable && m.court == null).toList();

    Map<BadmintonMatch, Set<Player>> matchPlayerConflicts =
        _getMatchPlayerConflicts(
      playingPlayers,
      playableMatches,
    );

    Map<Player, DateTime> restingPlayers = _getRestingPlayers(progressState);

    Map<BadmintonMatch, Set<Player>> restingPlayerConflicts =
        _getRestingPlayerConflicts(
      restingPlayers.keys.toSet(),
      playableMatches,
    );

    Map<MatchWaitingStatus, List<BadmintonMatch>> waitList = _createWaitList(
      matches,
      playableMatches,
      matchPlayerConflicts,
      restingPlayerConflicts,
    );

    List<BadmintonMatch> calloutWaitList = matches
        .where((m) => m.startTime == null && m.court != null)
        .sortedByCompare((m) => m.competition, compareCompetitions)
        .toList();

    List<BadmintonMatch> inProgressList = matches
        .where((m) => m.startTime != null && m.score == null)
        .sortedBy((m) => m.startTime!)
        .toList();

    _scheduleRestTimeUpdate(restingPlayers);

    MatchQueueState newState = state.copyWith(
      progressState: progressState,
      waitList: waitList,
      calloutWaitList: calloutWaitList,
      inProgressList: inProgressList,
      restingPlayers: restingPlayers,
    );

    if (state.queueMode == QueueMode.auto) {
      _callOutNextMatch(newState);
    }

    emit(newState);
  }

  void _callOutNextMatch(MatchQueueState queueState) async {
    Court? nextCourt = queueState.progressState!.openCourts.firstOrNull;
    BadmintonMatch? nextMatch =
        queueState.waitList[MatchWaitingStatus.waitingForCourt]?.firstOrNull;

    if (nextCourt == null || nextMatch == null) {
      return;
    }

    MatchData matchData = nextMatch.matchData!;

    submitMatchCourtAssignment(matchData, nextCourt);
  }

  Map<Player, DateTime> _getRestingPlayers(
    TournamentProgressState progressState,
  ) {
    DateTime now = DateTime.now().toUtc();
    Map<Player, DateTime> restingPlayers = {};
    for (MapEntry<Player, DateTime> entry
        in progressState.restingPlayers.entries) {
      int restTime = now.difference(entry.value).inMinutes;
      if (restTime < state.playerRestTime) {
        restingPlayers.putIfAbsent(entry.key, () => entry.value);
      }
    }

    return restingPlayers;
  }

  Map<BadmintonMatch, Set<Player>> _getMatchPlayerConflicts(
    Set<Player> playingPlayers,
    List<BadmintonMatch> playableMatches,
  ) {
    Map<BadmintonMatch, Set<Player>> matchPlayerConflicts = {
      for (BadmintonMatch match in playableMatches)
        match: playingPlayers.intersection(match.getPlayersOfMatch().toSet()),
    };

    return matchPlayerConflicts;
  }

  Map<BadmintonMatch, Set<Player>> _getRestingPlayerConflicts(
    Set<Player> restingPlayers,
    List<BadmintonMatch> playableMatches,
  ) {
    Map<BadmintonMatch, Set<Player>> restingPlayerConflicts = {
      for (BadmintonMatch match in playableMatches)
        match: restingPlayers.intersection(match.getPlayersOfMatch().toSet()),
    };

    return restingPlayerConflicts;
  }

  Map<MatchWaitingStatus, List<BadmintonMatch>> _createWaitList(
    List<BadmintonMatch> matches,
    List<BadmintonMatch> playableMatches,
    Map<BadmintonMatch, Set<Player>> matchPlayerConflicts,
    Map<BadmintonMatch, Set<Player>> restingPlayerConflicts,
  ) {
    Map<MatchWaitingStatus, List<BadmintonMatch>> waitList = {
      MatchWaitingStatus.waitingForCourt: playableMatches
          .where(
            (m) =>
                matchPlayerConflicts[m]!.isEmpty &&
                restingPlayerConflicts[m]!.isEmpty,
          )
          .sorted(compareMatches)
          .toList(),
      MatchWaitingStatus.waitingForRest: playableMatches
          .where(
            (m) =>
                matchPlayerConflicts[m]!.isEmpty &&
                restingPlayerConflicts[m]!.isNotEmpty,
          )
          .sortedByCompare((m) => m.competition, compareCompetitions)
          .toList(),
      MatchWaitingStatus.waitingForPlayer: playableMatches
          .where((m) => matchPlayerConflicts[m]!.isNotEmpty)
          .sortedByCompare((m) => m.competition, compareCompetitions)
          .toList(),
      MatchWaitingStatus.waitingForProgress: matches
          .where((m) => !m.isPlayable)
          .sortedByCompare((m) => m.competition, compareCompetitions)
          .toList(),
    };

    return waitList;
  }

  void _scheduleRestTimeUpdate(Map<Player, DateTime> restingPlayers) {
    if (_restTimer != null) {
      _restTimer!.cancel();
      _restTimer = null;
    }

    DateTime? nextRestDeadline = restingPlayers.values.sorted().firstOrNull;
    if (nextRestDeadline == null) {
      return;
    }

    DateTime now = DateTime.now().toUtc();
    Duration restDuration = nextRestDeadline.difference(now);

    _restTimer = Timer(restDuration, _onRestTimeUpdate);
  }

  void _onRestTimeUpdate() {
    tournamentChanged(state.progressState!);
  }
}
