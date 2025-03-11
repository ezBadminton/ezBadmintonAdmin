part of 'court_cubit.dart';

class CourtState extends CollectionQuerierState {
  const CourtState({
    this.loadingStatus = LoadingStatus.loading,
    this.occupied = const {},
    this.collections = const [],
  });

  @override
  final LoadingStatus loadingStatus;

  final Map<Court, MatchContext> occupied;

  @override
  final List<List<Model>> collections;

  CourtState copyWith({
    LoadingStatus? loadingStatus,
    Map<Court, MatchContext>? occupied,
    List<List<Model>>? collections,
  }) =>
      CourtState(
        loadingStatus: loadingStatus ?? this.loadingStatus,
        occupied: occupied ?? this.occupied,
        collections: collections ?? this.collections,
      );
}
