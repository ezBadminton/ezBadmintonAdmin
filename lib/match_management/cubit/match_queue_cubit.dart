import 'package:ez_badminton_admin_app/widgets/tournament_context/tournament_context.dart';
import 'package:model_repository/model_repository.dart';
import 'package:ez_badminton_admin_app/collection_queries/collection_querier.dart';
import 'package:ez_badminton_admin_app/widgets/loading_screen/loading_screen.dart';

part 'match_queue_state.dart';

class MatchQueueCubit extends CollectionQuerierCubit<MatchQueueState> {
  MatchQueueCubit({
    required ModelStore<TournamentEvent> tournamentRepository,
    required ModelStore<Schedule> scheduleStore,
    required ModelStore<ScheduledMatch> scheduledMatchStore,
  }) : super(
          modelStores: [
            tournamentRepository,
            scheduleStore,
            scheduledMatchStore,
          ],
          MatchQueueState(),
        );

  @override
  void onCollectionUpdate(
    List<List<Model>> collections,
    CollectionUpdateEvent<Model>? updateEvent,
  ) {
    MatchQueueState updatedState = state.copyWith(
      collections: collections,
      loadingStatus: LoadingStatus.done,
    );

    var schedule = updatedState.getCollection<Schedule>().firstOrNull;
    if (schedule == null) {
      emit(updatedState);
      return;
    }

    List<ScheduledRound> queuedRounds = [];
    List<MatchContext> readyMatches = [];
    List<MatchContext> runningMatches = [];

    for (var round in schedule.roundQueue) {
      var tPlan = round.competition.tournamentPlan!;
      var isWaiting = false;
      for (var match in round.matches) {
        var mContext = MatchContext(
          tournamentPlan: tPlan,
          scheduledMatch: match,
        );
        switch (match.status) {
          case ScheduleStatus.done:
            break;
          case ScheduleStatus.scoreUnknown:
          case ScheduleStatus.inProgress:
            runningMatches.add(mContext);
          case ScheduleStatus.ready:
            readyMatches.add(mContext);
          case ScheduleStatus.courtWait:
          case ScheduleStatus.playerRest:
          case ScheduleStatus.playerWait:
          case ScheduleStatus.wait:
            isWaiting = true;
        }
      }
      if (isWaiting) {
        queuedRounds.add(round);
      }
    }
    updatedState = updatedState.copyWith(
      queuedRounds: queuedRounds,
      readyMatches: readyMatches,
      runningMatches: runningMatches,
    );

    emit(updatedState);
  }
}
