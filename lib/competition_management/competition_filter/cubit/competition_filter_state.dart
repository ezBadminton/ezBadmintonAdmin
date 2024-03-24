part of 'competition_filter_cubit.dart';

class CompetitionFilterState extends CollectionQuerierState
    implements PredicateConsumerState {
  CompetitionFilterState({
    this.loadingStatus = LoadingStatus.loading,
    this.filterPredicate,
    this.collections = const [],
  });

  @override
  final LoadingStatus loadingStatus;

  @override
  final FilterPredicate? filterPredicate;

  @override
  final List<List<Model>> collections;

  CompetitionFilterState copyWith({
    LoadingStatus? loadingStatus,
    List<List<Model>>? collections,
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
