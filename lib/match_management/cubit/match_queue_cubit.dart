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
    List<CollectionUpdateEvent<Model>> updateEvents,
  ) {
    MatchQueueState updatedState = state.copyWith(
      collections: collections,
      loadingStatus: LoadingStatus.done,
    );

    var schedule = updatedState.getCollection<Schedule>().firstOrNull;
    var matchDataMap = <TournamentMatch, ScheduledMatchContext>{};
    for (var round in schedule?.roundQueue ?? <ScheduledRound>[]) {
      for (var match in round.matches) {
        matchDataMap[match.match] = ScheduledMatchContext(
          round.competition.tournamentPlan!,
          match,
        );
      }
    }
    updatedState = updatedState.copyWith(
      schedule: schedule,
      matchDataMap: matchDataMap,
    );

    emit(updatedState);
  }
}
