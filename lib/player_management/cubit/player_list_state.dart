part of 'player_list_cubit.dart';

@immutable
class PlayerListState {
  const PlayerListState({
    this.loadingStatus = LoadingStatus.loading,
    this.filteredPlayers = const [],
    this.allPlayers = const [],
    this.playerCompetitions = const {},
  });

  final LoadingStatus loadingStatus;
  final List<Player> filteredPlayers;
  final List<Player> allPlayers;
  final Map<Player, List<Competition>> playerCompetitions;

  PlayerListState copyWith({
    LoadingStatus? loadingStatus,
    List<Player>? filteredPlayers,
    List<Player>? allPlayers,
    Map<Player, List<Competition>>? playerCompetitions,
  }) {
    return PlayerListState(
      loadingStatus: loadingStatus ?? this.loadingStatus,
      filteredPlayers: filteredPlayers ?? this.filteredPlayers,
      allPlayers: allPlayers ?? this.allPlayers,
      playerCompetitions: playerCompetitions ?? this.playerCompetitions,
    );
  }
}
