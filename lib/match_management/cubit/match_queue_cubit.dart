import 'dart:async';

import 'package:collection/collection.dart';
import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/badminton_tournament_ops/badminton_match.dart';
import 'package:ez_badminton_admin_app/badminton_tournament_ops/cubit/tournament_progress_cubit.dart';
import 'package:ez_badminton_admin_app/collection_queries/collection_querier.dart';
import 'package:ez_badminton_admin_app/widgets/loading_screen/loading_screen.dart';

part 'match_queue_state.dart';

class MatchQueueCubit extends CollectionFetcherCubit<MatchQueueState> {
  MatchQueueCubit({
    required CollectionRepository<Tournament> tournamentRepository,
  }) : super(
          collectionRepositories: [
            tournamentRepository,
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

    List<BadmintonMatch> calloutWaitList =
        matches.where((m) => m.startTime == null && m.court != null).toList();

    List<BadmintonMatch> inProgressList =
        matches.where((m) => m.startTime != null && m.score == null).toList();

    _scheduleRestTimeUpdate(restingPlayers);

    emit(state.copyWith(
      progressState: progressState,
      waitList: waitList,
      calloutWaitList: calloutWaitList,
      inProgressList: inProgressList,
      restingPlayers: restingPlayers,
    ));
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
          .toList(),
      MatchWaitingStatus.waitingForRest: playableMatches
          .where(
            (m) =>
                matchPlayerConflicts[m]!.isEmpty &&
                restingPlayerConflicts[m]!.isNotEmpty,
          )
          .toList(),
      MatchWaitingStatus.waitingForPlayer: playableMatches
          .where((m) => matchPlayerConflicts[m]!.isNotEmpty)
          .toList(),
      MatchWaitingStatus.waitingForProgress:
          matches.where((m) => !m.isPlayable).toList(),
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
