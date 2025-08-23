import 'package:ez_badminton_admin_app/collection_queries/collection_querier.dart';
import 'package:ez_badminton_admin_app/widgets/loading_screen/loading_screen.dart';
import 'package:model_repository/model_repository.dart';

part 'tournament_plan_state.dart';

class TournamentPlanCubit extends CollectionQuerierCubit<TournamentPlanState> {
  TournamentPlanCubit({
    required ModelStore<TournamentPlan> tournamentPlanStore,
  }) : super(
          modelStores: [
            tournamentPlanStore,
          ],
          const TournamentPlanState(),
        );

  @override
  void onCollectionUpdate(
    List<List<Model>> collections,
    List<CollectionUpdateEvent<Model>>? updateEvents,
  ) {
    var drawnTournaments = <Competition, TournamentPlan>{};
    var runningTournaments = <Competition, TournamentPlan>{};

    var updatedState = state.copyWith(
      loadingStatus: LoadingStatus.done,
      collections: collections,
    );

    var plans = updatedState.getCollection<TournamentPlan>();
    for (var plan in plans) {
      if (plan.started) {
        runningTournaments[plan.competition] = plan;
      } else {
        drawnTournaments[plan.competition] = plan;
      }
    }

    updatedState = updatedState.copyWith(
      drawnTournaments: drawnTournaments,
      runningTournaments: runningTournaments,
    );

    emit(updatedState);
  }
}
