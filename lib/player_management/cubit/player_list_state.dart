part of 'player_list_cubit.dart';

@immutable
class PlayerListState extends CollectionQuerierState {
  const PlayerListState({
    this.loadingStatus = LoadingStatus.loading,
    this.filteredPlayers = const [],
    this.playerCompetitions = const {},
    this.collections = const {},
  });

  final LoadingStatus loadingStatus;
  final List<Player> filteredPlayers;
  final Map<Player, List<Competition>> playerCompetitions;

  final Map<Type, List<Model>> collections;

  PlayerListState copyWith({
    LoadingStatus? loadingStatus,
    List<Player>? filteredPlayers,
    Map<Player, List<Competition>>? playerCompetitions,
    Map<Type, List<Model>>? collections,
  }) {
    return PlayerListState(
      loadingStatus: loadingStatus ?? this.loadingStatus,
      filteredPlayers: filteredPlayers ?? this.filteredPlayers,
      playerCompetitions: playerCompetitions ?? this.playerCompetitions,
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

  @override
  List<M> getCollection<M extends Model>() {
    return collections[M] as List<M>;
  }
}
