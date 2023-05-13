part of 'player_list_cubit.dart';

@immutable
class PlayerListState {
  const PlayerListState(
      {this.filteredPlayers = const [],
      this.allPlayers = const [],
      this.competitions = const [],
      this.playerCompetitions = const {}});

  final List<Player> filteredPlayers;
  final List<Player> allPlayers;
  final List<Competition> competitions;
  final Map<Player, List<Competition>> playerCompetitions;

  PlayerListState copyWith({
    List<Player>? filteredPlayers,
    List<Player>? allPlayers,
    List<Competition>? competitions,
    Map<Player, List<Competition>>? playerCompetitions,
  }) {
    return PlayerListState(
      filteredPlayers: filteredPlayers ?? this.filteredPlayers,
      allPlayers: allPlayers ?? this.allPlayers,
      competitions: competitions ?? this.competitions,
      playerCompetitions: playerCompetitions ?? this.playerCompetitions,
    );
  }
}
