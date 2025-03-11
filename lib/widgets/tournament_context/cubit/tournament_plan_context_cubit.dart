import 'package:collection/collection.dart';
import 'package:ez_badminton_admin_app/collection_queries/collection_querier.dart';
import 'package:ez_badminton_admin_app/widgets/loading_screen/loading_screen.dart';
import 'package:model_repository/model_repository.dart';

part 'tournament_plan_context_state.dart';

class TournamentPlanContextCubit
    extends CollectionQuerierCubit<TournamentPlanContextState> {
  TournamentPlanContextCubit({
    required this.competition,
    required ModelStore<TournamentPlan> tournamentPlanStore,
  }) : super(
          modelStores: [
            tournamentPlanStore,
          ],
          TournamentPlanContextState(
            tournamentPlan: competition.tournamentPlan,
          ),
        );

  final Competition competition;

  @override
  void onCollectionUpdate(
    List<List<Model>> collections,
    CollectionUpdateEvent<Model>? updateEvent,
  ) {
    var updatedState = state.copyWith(
      loadingStatus: LoadingStatus.done,
      collections: collections,
    );

    var plan = updatedState
        .getCollection<TournamentPlan>()
        .firstWhereOrNull((plan) => plan.competition == competition);

    if (plan == null) {
      return;
    }

    updatedState = updatedState.copyWith(tournamentPlan: plan);
    emit(updatedState);
  }
}
