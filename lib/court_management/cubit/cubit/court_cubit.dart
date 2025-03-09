import 'package:ez_badminton_admin_app/collection_queries/collection_querier.dart';
import 'package:ez_badminton_admin_app/widgets/loading_screen/loading_screen.dart';
import 'package:ez_badminton_admin_app/widgets/tournament_context/tournament_context.dart';
import 'package:model_repository/model_repository.dart';

part 'court_state.dart';

class CourtCubit extends CollectionQuerierCubit<CourtState> {
  CourtCubit({
    required ModelStore<Court> courtStore,
    required ModelStore<ScheduledMatch> scheduledMatchStore,
    required ModelStore<ScheduledRound> scheduledRoundStore,
  }) : super(
          modelStores: [
            courtStore,
            scheduledMatchStore,
            scheduledRoundStore,
          ],
          CourtState(),
        );

  @override
  void onCollectionUpdate(
    List<List<Model>> collections,
    List<CollectionUpdateEvent<Model>> updateEvents,
  ) {
    var updatedState = state.copyWith(
      loadingStatus: LoadingStatus.done,
      collections: collections,
    );

    var occupied = <Court, ScheduledMatchContext>{};
    for (var round in updatedState.getCollection<ScheduledRound>()) {
      for (var match in round.matches) {
        switch (match.status) {
          case ScheduleStatus.inProgress:
          case ScheduleStatus.ready:
            break;
          default:
            continue;
        }

        var court = match.match.court;
        if (court == null) {
          continue;
        }
        var matchContext = ScheduledMatchContext(
          round.competition.tournamentPlan!,
          match,
        );

        occupied[court] = matchContext;
      }
    }
    updatedState = updatedState.copyWith(occupied: occupied);
    emit(updatedState);
  }
}
