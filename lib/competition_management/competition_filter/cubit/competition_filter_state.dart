part of 'competition_filter_cubit.dart';

class CompetitionFilterState
    extends CollectionFetcherState<CompetitionFilterState>
    implements PredicateConsumerState {
  CompetitionFilterState({
    this.loadingStatus = LoadingStatus.loading,
    this.filterPredicate,
    super.collections = const {},
  });

  final LoadingStatus loadingStatus;

  @override
  final FilterPredicate? filterPredicate;

  CompetitionFilterState copyWith({
    LoadingStatus? loadingStatus,
    Map<Type, List<Model>>? collections,
  }) {
    return CompetitionFilterState(
      loadingStatus: loadingStatus ?? this.loadingStatus,
      collections: collections ?? this.collections,
      filterPredicate: null,
    );
  }

  CompetitionFilterState copyWithPredicate({
    required FilterPredicate filterPredicate,
  }) =>
      CompetitionFilterState(
        loadingStatus: loadingStatus,
        collections: collections,
        filterPredicate: filterPredicate,
      );
}
