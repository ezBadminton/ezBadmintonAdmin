import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/badminton_tournament_ops/badminton_match.dart';
import 'package:ez_badminton_admin_app/badminton_tournament_ops/cubit/tournament_progress_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'match_queue_state.dart';

class MatchQueueCubit extends Cubit<MatchQueueState> {
  MatchQueueCubit() : super(MatchQueueState());

  void tournamentChanged(TournamentProgressState progressState) {
    List<BadmintonMatch> matches = progressState.runningTournaments.values
        .expand((t) => t.matches)
        .where((match) => !match.isBye)
        .toList();

    Set<Player> playingPlayers = progressState.playingPlayers.keys.toSet();

    List<BadmintonMatch> playableMatches =
        matches.where((m) => m.isPlayable && m.court == null).toList();

    Map<BadmintonMatch, Set<Player>> matchPlayerConflicts = {
      for (BadmintonMatch match in playableMatches)
        match: playingPlayers.intersection(match.getPlayersOfMatch().toSet()),
    };

    Map<MatchWaitingStatus, List<BadmintonMatch>> waitList = {
      MatchWaitingStatus.waitingForCourt: playableMatches
          .where((m) => matchPlayerConflicts[m]!.isEmpty)
          .toList(),
      MatchWaitingStatus.waitingForPlayer: playableMatches
          .where((m) => matchPlayerConflicts[m]!.isNotEmpty)
          .toList(),
      MatchWaitingStatus.waitingForProgress:
          matches.where((m) => !m.isPlayable).toList(),
    };

    List<BadmintonMatch> calloutWaitList =
        matches.where((m) => m.startTime == null && m.court != null).toList();

    List<BadmintonMatch> inProgressList =
        matches.where((m) => m.startTime != null && m.score == null).toList();

    emit(state.copyWith(
      waitList: waitList,
      calloutWaitList: calloutWaitList,
      inProgressList: inProgressList,
    ));
  }
}
