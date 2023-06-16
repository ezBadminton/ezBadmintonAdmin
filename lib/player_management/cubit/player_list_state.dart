part of 'player_list_cubit.dart';

@immutable
class PlayerListState extends CollectionFetcherState with CollectionGetter {
  const PlayerListState({
    this.loadingStatus = LoadingStatus.loading,
    this.filteredPlayers = const [],
    this.competitionRegistrations = const {},
    this.filters = const {},
    this.sortingComparator = const CreationDateComparator(),
    this.collections = const {},
  });

  final LoadingStatus loadingStatus;
  final List<Player> filteredPlayers;
  final Map<Player, List<CompetitionRegistration>> competitionRegistrations;

  final Map<Type, Predicate> filters;
  final ListSortingComparator<Player> sortingComparator;

  @override
  final Map<Type, List<Model>> collections;

  PlayerListState copyWith({
    LoadingStatus? loadingStatus,
    List<Player>? filteredPlayers,
    Map<Player, List<CompetitionRegistration>>? competitionRegistrations,
    Map<Type, Predicate>? filters,
    ListSortingComparator<Player>? sortingComparator,
    Map<Type, List<Model>>? collections,
  }) {
    return PlayerListState(
      loadingStatus: loadingStatus ?? this.loadingStatus,
      filteredPlayers: filteredPlayers ?? this.filteredPlayers,
      competitionRegistrations:
          competitionRegistrations ?? this.competitionRegistrations,
      filters: filters ?? this.filters,
      sortingComparator: sortingComparator ?? this.sortingComparator,
      collections: collections ?? this.collections,
    );
  }

  @override
  PlayerListState copyWithCollection({
    required Type modelType,
    required List<Model> collection,
  }) {
    var newCollections = Map.of(collections);
    newCollections.remove(modelType);
    newCollections.putIfAbsent(modelType, () => collection);
    return copyWith(collections: Map.unmodifiable(newCollections));
  }
}
