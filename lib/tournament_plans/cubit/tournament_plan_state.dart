part of 'tournament_plan_cubit.dart';

class TournamentPlanState extends CollectionQuerierState {
  const TournamentPlanState({
    this.loadingStatus = LoadingStatus.loading,
    this.drawnTournaments = const {},
    this.runningTournaments = const {},
    this.collections = const [],
  });

  @override
  final LoadingStatus loadingStatus;

  final Map<Competition, TournamentPlan> drawnTournaments;
  final Map<Competition, TournamentPlan> runningTournaments;

  @override
  final List<List<Model>> collections;

  TournamentPlanState copyWith({
    LoadingStatus? loadingStatus,
    Map<Competition, TournamentPlan>? drawnTournaments,
    Map<Competition, TournamentPlan>? runningTournaments,
    List<List<Model>>? collections,
  }) =>
      TournamentPlanState(
        loadingStatus: loadingStatus ?? this.loadingStatus,
        drawnTournaments: drawnTournaments ?? this.drawnTournaments,
        runningTournaments: runningTournaments ?? this.runningTournaments,
        collections: collections ?? this.collections,
      );
}
