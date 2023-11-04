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
      MatchWaitingStatus.waitingForCourt: _createWaitingForCourtList(
        playableMatches,
        matchPlayerConflicts,
        restingPlayerConflicts,
      ),
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

  /// Filters the matches that are ready to play and waiting for court
  /// assignment. Also sorts them in the order that they should be played.
  List<BadmintonMatch> _createWaitingForCourtList(
    List<BadmintonMatch> playableMatches,
    Map<BadmintonMatch, Set<Player>> matchPlayerConflicts,
    Map<BadmintonMatch, Set<Player>> restingPlayerConflicts,
  ) {
    List<BadmintonMatch> waitingForCourt = playableMatches
        .where(
          (m) =>
              matchPlayerConflicts[m]!.isEmpty &&
              restingPlayerConflicts[m]!.isEmpty,
        )
        .toList();

    List<BadmintonMatch> sortedWaitingForCourt = waitingForCourt.sorted(
      (a, b) => _compareWaitingMatches(waitingForCourt, a, b),
    );

    return sortedWaitingForCourt;
  }

  /// Determines which of the matches [match1] or [match2] should be played
  /// first.
  ///
  /// For this purpose the index of both matches within the list of waiting
  /// matches of their respective tournament is compared.
  /// The earlier match goes first.
  ///
  /// If they have the same index they are ordered according to the
  /// competition that they are played in. The comparison is done by the
  /// [compareCompetitions] method.
  int _compareWaitingMatches(
    List<BadmintonMatch> waitingForCourt,
    BadmintonMatch match1,
    BadmintonMatch match2,
  ) {
    List<BadmintonMatch> matches1 = match1.round!.tournament.matches
        .cast<BadmintonMatch>()
        .where((m) => waitingForCourt.contains(m))
        .toList();
    List<BadmintonMatch> matches2 = match2.round!.tournament.matches
        .cast<BadmintonMatch>()
        .where((m) => waitingForCourt.contains(m))
        .toList();

    int matchIndex1 = matches1.indexOf(match1);
    int matchIndex2 = matches2.indexOf(match2);

    assert(matchIndex1 != -1 && matchIndex2 != -1);

    int matchIndexComparison = matchIndex1.compareTo(matchIndex2);

    if (matchIndexComparison != 0) {
      return matchIndexComparison;
    }

    int competitionComparison =
        compareCompetitions(match1.competition, match2.competition);

    return competitionComparison;
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
