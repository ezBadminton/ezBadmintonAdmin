part of 'player_filter_cubit.dart';

@immutable
class PlayerFilterState extends CollectionFetcherState<PlayerFilterState>
    implements PredicateConsumerState {
  const PlayerFilterState({
    this.loadingStatus = LoadingStatus.loading,
    this.filterPredicate,
    super.collections = const {},
  });

  final LoadingStatus loadingStatus;
  @override
  final FilterPredicate? filterPredicate;

  PlayerFilterState copyWith({
    LoadingStatus? loadingStatus,
    List<PlayingLevel>? allPlayingLevels,
    Map<Type, List<Model>>? collections,
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
