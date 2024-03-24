part of 'player_filter_cubit.dart';

@immutable
class PlayerFilterState extends CollectionQuerierState
    implements PredicateConsumerState {
  const PlayerFilterState({
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

  PlayerFilterState copyWith({
    LoadingStatus? loadingStatus,
    List<PlayingLevel>? allPlayingLevels,
    List<List<Model>>? collections,
  }) =>
      PlayerFilterState(
        loadingStatus: loadingStatus ?? this.loadingStatus,
        collections: collections ?? this.collections,
        filterPredicate: null,
      );

  PlayerFilterState copyWithPredicate({
    required FilterPredicate filterPredicate,
  }) =>
      PlayerFilterState(
        loadingStatus: loadingStatus,
        collections: collections,
        filterPredicate: filterPredicate,
      );
}
