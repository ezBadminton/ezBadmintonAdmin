part of 'tournament_plan_context_cubit.dart';

class TournamentPlanContextState extends CollectionQuerierState {
  TournamentPlanContextState({
    this.loadingStatus = LoadingStatus.done,
    this.tournamentPlan,
    this.collections = const [],
  });

  @override
  final LoadingStatus loadingStatus;

  final TournamentPlan? tournamentPlan;

  @override
  final List<List<Model>> collections;

  TournamentPlanContextState copyWith({
    LoadingStatus? loadingStatus,
    TournamentPlan? tournamentPlan,
    List<List<Model>>? collections,
  }) {
    return TournamentPlanContextState(
      loadingStatus: loadingStatus ?? this.loadingStatus,
      tournamentPlan: tournamentPlan ?? this.tournamentPlan,
      collections: collections ?? this.collections,
    );
  }
}
