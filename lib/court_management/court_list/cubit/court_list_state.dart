part of 'court_list_cubit.dart';

class CourtListState extends CollectionFetcherState<CourtListState> {
  CourtListState({
    this.loadingStatus = LoadingStatus.loading,
    this.courtMap = const {},
    super.collections = const {},
  });

  final LoadingStatus loadingStatus;
  final Map<Gymnasium, List<Court>> courtMap;

  CourtListState copyWith({
    LoadingStatus? loadingStatus,
    Map<Gymnasium, List<Court>>? courtMap,
    Map<Type, List<Model>>? collections,
  }) {
    return CourtListState(
      loadingStatus: loadingStatus ?? this.loadingStatus,
      courtMap: courtMap ?? this.courtMap,
      collections: collections ?? this.collections,
    );
  }
}
