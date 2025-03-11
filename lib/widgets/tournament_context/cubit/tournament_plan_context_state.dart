part of 'tournament_plan_context_cubit.dart';

class TournamentPlanContextState extends CollectionQuerierState {
  TournamentPlanContextState({
    this.loadingStatus = LoadingStatus.loading,
    TournamentPlan? tournamentPlan,
    this.collections = const [],
  }) : _tournamentPlan = tournamentPlan;

  @override
  final LoadingStatus loadingStatus;

  final TournamentPlan? _tournamentPlan;

  TournamentPlan get tournamentPlan => _tournamentPlan!;

  @override
  final List<List<Model>> collections;

  TournamentPlanContextState copyWith({
    LoadingStatus? loadingStatus,
    TournamentPlan? tournamentPlan,
    List<List<Model>>? collections,
  }) {
    return TournamentPlanContextState(
      loadingStatus: loadingStatus ?? this.loadingStatus,
      tournamentPlan: tournamentPlan ?? _tournamentPlan,
      collections: collections ?? this.collections,
    );
  }
}
