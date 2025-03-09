part of 'court_list_cubit.dart';

class CourtListState extends CollectionQuerierState {
  CourtListState({
    this.loadingStatus = LoadingStatus.loading,
    this.courtMap = const {},
    this.collections = const [],
  });

  @override
  final LoadingStatus loadingStatus;
  final Map<Gymnasium, List<Court>> courtMap;

  @override
  final List<List<Model>> collections;

  CourtListState copyWith({
    LoadingStatus? loadingStatus,
    Map<Gymnasium, List<Court>>? courtMap,
    List<List<Model>>? collections,
  }) {
    return CourtListState(
      loadingStatus: loadingStatus ?? this.loadingStatus,
      courtMap: courtMap ?? this.courtMap,
      collections: collections ?? this.collections,
    );
  }
}
