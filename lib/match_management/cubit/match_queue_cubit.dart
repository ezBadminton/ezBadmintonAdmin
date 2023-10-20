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

    Map<MatchWaitingStatus, List<BadmintonMatch>> waitList = {
      MatchWaitingStatus.waitingForCourt:
          matches.where((m) => m.isPlayable && m.court == null).toList(),
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
