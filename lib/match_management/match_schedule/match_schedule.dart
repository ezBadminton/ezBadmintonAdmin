import 'package:collection/collection.dart';
import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/badminton_tournament_ops/badminton_match.dart';
import 'package:ez_badminton_admin_app/badminton_tournament_ops/cubit/tournament_progress_cubit.dart';
import 'package:ez_badminton_admin_app/list_sorting/comparator/list_sorting_comparator.dart';
import 'package:ez_badminton_admin_app/utils/sorting.dart';

typedef MatchScheduler = MatchSchedule Function(
  TournamentProgressState progressState,
  int playerRestTime,
);

abstract class MatchSchedule {
  /// The matches that are waiting to be played.
  /// See [MatchWaitingStatus] to get information about the different wait lists
  /// in this map.
  Map<MatchWaitingStatus, List<BadmintonMatch>> get schedule;

  /// List of matches that have a court assigned and need to be called out to
  /// the players.
  List<BadmintonMatch> get calloutWaitList;

  /// List of matches that are currently running.
  List<BadmintonMatch> get inProgressList;

  /// All players that are currently in their recovery time mapped to the
  /// timestamp when that time ends.
  Map<Player, DateTime> get restingDeadlines;
}

/// A [ParallelMatchSchedule] schedules the matches evenly from
/// all competitions that are running in parallel.
///
/// It does this by always prioritizing the competition that had to wait the
/// longest since one of its matches was assigned a court. If a competition
/// has no matches that are ready to play (e.g. because of player rest time),
/// then the next highest priority competition gets scheduled and as soon as
/// the highest priority competition has a match ready again,
/// it is put on top of the schedule.
class ParallelMatchSchedule implements MatchSchedule {
  ParallelMatchSchedule({
    required this.progressState,
    required this.playerRestTime,
  }) {
    _initSchedule();
  }

  final TournamentProgressState progressState;
  final int playerRestTime;

  @override
  late final Map<MatchWaitingStatus, List<BadmintonMatch>> schedule;
  @override
  late final List<BadmintonMatch> calloutWaitList;
  @override
  late final List<BadmintonMatch> inProgressList;
  @override
  late final Map<Player, DateTime> restingDeadlines;

  /// All matches of the running tournament.
  ///
  /// Planned, in progress and completed.
  late final List<BadmintonMatch> _allMatches;

  /// All matches that are planned and have both opponents determined.
  late final List<BadmintonMatch> _qualifiedMatches;

  /// All matches with the set of their participants who are unavailable
  /// because they are currently playing in another match.
  ///
  /// When the set is empty the match has no player conflicts.
  late final Map<BadmintonMatch, Set<Player>> _matchPlayerConflicts;

  /// All matches with the set of their participants who are unavailable
  /// because they are in their resting time.
  ///
  /// When the set is empty the match has no resting conflicts;
  late final Map<BadmintonMatch, Set<Player>> _restingPlayerConflicts;

  /// All running competitions ordered by how long ago a match from that
  /// competition was last started.
  ///
  /// The competition that has waited the longest gets top priority and its
  /// next match is put on top of the match queue.
  late final List<Competition> _queuePriorityList;

  /// All matches of each running competition that are waiting for a court and
  /// have no conflicts.
  late final Map<Competition, List<BadmintonMatch>> _competitionReadyMatches;

  void _initSchedule() {
    _allMatches = progressState.runningTournaments.values
        .expand((t) => t.matches)
        .where((match) => !match.isBye && !match.isWalkover)
        .toList();

    _qualifiedMatches =
        _allMatches.where((m) => m.court == null && m.isPlayable).toList();

    calloutWaitList = _allMatches
        .where((m) => m.startTime == null && m.court != null)
        .sortedByCompare((m) => m.competition, compareCompetitions)
        .toList();

    inProgressList = _allMatches
        .where((m) => m.inProgress)
        .sortedBy((m) => m.startTime!)
        .toList();

    _createMatchPlayerConflicts();
    _createRestingDeadlines();
    _createRestingPlayerConflicts();
    _createCompetitionReadyMatches();
    _createQueuePriorityList();

    _createSchedule();
  }

  void _createMatchPlayerConflicts() {
    Set<Player> playingPlayers = progressState.playingPlayers.keys.toSet();

    _matchPlayerConflicts = {
      for (BadmintonMatch match in _qualifiedMatches)
        match: playingPlayers.intersection(match.getPlayersOfMatch().toSet()),
    };
  }

  void _createRestingDeadlines() {
    Duration restDuration = Duration(minutes: playerRestTime);
    DateTime now = DateTime.now().toUtc();

    restingDeadlines = Map.fromEntries(
      progressState.lastPlayerMatches.entries
          .where(
            (entry) => now.difference(entry.value) < restDuration,
          )
          .map(
            (entry) => MapEntry(entry.key, entry.value.add(restDuration)),
          ),
    );
  }

  void _createRestingPlayerConflicts() {
    Set<Player> restingPlayers = restingDeadlines.keys.toSet();

    _restingPlayerConflicts = {
      for (BadmintonMatch match in _qualifiedMatches)
        match: restingPlayers.intersection(match.getPlayersOfMatch().toSet()),
    };
  }

  void _createCompetitionReadyMatches() {
    _competitionReadyMatches =
        progressState.runningTournaments.map((competition, tournament) {
      List<BadmintonMatch> readyMatches = tournament.matches
          .where((m) => m.isPlayable && m.court == null && !m.isWalkover)
          .where(
            (m) =>
                _matchPlayerConflicts[m]!.isEmpty &&
                _restingPlayerConflicts[m]!.isEmpty,
          )
          .toList();

      return MapEntry(competition, readyMatches);
    });
  }

  void _createQueuePriorityList() {
    DateTime zeroTime = DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);

    Map<Competition, DateTime> lastCourtAssignmentTimes =
        progressState.runningTournaments.map(
      (competition, tournament) {
        Iterable<DateTime> courtAssignmentTimes = tournament.matches
            .where((m) => m.matchData!.courtAssignmentTime != null)
            .map((m) => m.matchData!.courtAssignmentTime!);
        DateTime lastCourtAssignmentTime = courtAssignmentTimes.fold(
          zeroTime,
          (previousValue, element) =>
              element.isAfter(previousValue) ? element : previousValue,
        );

        return MapEntry(competition, lastCourtAssignmentTime);
      },
    );

    compareTimes(Competition a, Competition b) =>
        lastCourtAssignmentTimes[a]!.compareTo(lastCourtAssignmentTimes[b]!);

    // The priority is primarily sorted by the last court assignment time.
    // This way the longest waiting competition has the first priority.
    // When the time is equal the competitions are ordered by the
    // compareCompetitions method.
    Comparator<Competition> priorityComparator =
        nestComparators(compareTimes, compareCompetitions);

    _queuePriorityList =
        lastCourtAssignmentTimes.keys.sorted(priorityComparator);
  }

  void _createSchedule() {
    schedule = {
      MatchWaitingStatus.waitingForCourt: _createWaitingForCourtList(),
      MatchWaitingStatus.waitingForRest: _qualifiedMatches
          .where(
            (m) =>
                _matchPlayerConflicts[m]!.isEmpty &&
                _restingPlayerConflicts[m]!.isNotEmpty,
          )
          .sortedByCompare((m) => m.competition, compareCompetitions)
          .toList(),
      MatchWaitingStatus.waitingForPlayer: _qualifiedMatches
          .where((m) => _matchPlayerConflicts[m]!.isNotEmpty)
          .sortedByCompare((m) => m.competition, compareCompetitions)
          .toList(),
      MatchWaitingStatus.waitingForProgress: _allMatches
          .where((m) => !m.isPlayable)
          .sortedByCompare((m) => m.competition, compareCompetitions)
          .toList(),
    };
  }

  List<BadmintonMatch> _createWaitingForCourtList() {
    compareMatchIndex(BadmintonMatch a, BadmintonMatch b) {
      int indexA = _competitionReadyMatches[a.competition]!.indexOf(a);
      int indexB = _competitionReadyMatches[b.competition]!.indexOf(b);

      assert(indexA >= 0 && indexB >= 0);

      return indexA.compareTo(indexB);
    }

    compareCompetitionPriority(BadmintonMatch a, BadmintonMatch b) {
      int prioA = _queuePriorityList.indexOf(a.competition);
      int prioB = _queuePriorityList.indexOf(b.competition);

      assert(prioA >= 0 && prioB >= 0);

      return prioA.compareTo(prioB);
    }

    // The match priority is primarily sorted by the match's index in its
    // competition's ready matches. When two matches are from different
    // competitions and have the same index, the competition's priority decides.
    Comparator<BadmintonMatch> matchPriorityComparator =
        nestComparators(compareMatchIndex, compareCompetitionPriority);

    List<BadmintonMatch> waitingForCourt = _qualifiedMatches
        .where(
          (m) =>
              _matchPlayerConflicts[m]!.isEmpty &&
              _restingPlayerConflicts[m]!.isEmpty,
        )
        .sorted(matchPriorityComparator);

    return waitingForCourt;
  }
}

enum MatchWaitingStatus {
  /// Matches that are ready to go and just need to be assigned
  /// to an open court.
  waitingForCourt,

  /// Matches that can't start because at least one participant has not had
  /// their rest time since their last match.
  waitingForRest,

  /// Matches  that can't start because at least one participant is currently
  /// playing in another match.
  waitingForPlayer,

  /// Matches that can't start because the opponents are not determined yet.
  /// For example the final has to wait for progress until both semi-finals are
  /// finished.
  waitingForProgress,
}
