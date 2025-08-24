part of 'player_list_cubit.dart';

@immutable
class PlayerListState extends CollectionQuerierState
    implements SortedListState<Player> {
  const PlayerListState({
    this.loadingStatus = LoadingStatus.loading,
    this.filteredPlayers = const [],
    this.competitionRegistrations = const {},
    this.playersLookingForTeam = const {},
    this.filters = const {},
    this.sortingComparator = const CreationDateComparator(),
    this.collections = const [],
  });

  @override
  final LoadingStatus loadingStatus;
  final List<Player> filteredPlayers;
  final Map<Player, List<Registration>> competitionRegistrations;
  final Set<Player> playersLookingForTeam;

  final Map<Type, Predicate> filters;
  @override
  final ListSortingComparator<Player> sortingComparator;

  @override
  final List<List<Model>> collections;

  PlayerListState copyWith({
    LoadingStatus? loadingStatus,
    List<Player>? filteredPlayers,
    Map<Player, List<Registration>>? competitionRegistrations,
    Set<Player>? playersLookingForTeam,
    Map<Type, Predicate>? filters,
    ListSortingComparator<Player>? sortingComparator,
    List<List<Model>>? collections,
  }) {
    return PlayerListState(
      loadingStatus: loadingStatus ?? this.loadingStatus,
      filteredPlayers: filteredPlayers ?? this.filteredPlayers,
      competitionRegistrations:
          competitionRegistrations ?? this.competitionRegistrations,
      playersLookingForTeam:
          playersLookingForTeam ?? this.playersLookingForTeam,
      filters: filters ?? this.filters,
      sortingComparator: sortingComparator ?? this.sortingComparator,
      collections: collections ?? this.collections,
    );
  }
}
