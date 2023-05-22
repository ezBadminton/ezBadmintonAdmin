part of 'player_list_cubit.dart';

@immutable
class PlayerListState {
  const PlayerListState({
    this.loadingStatus = LoadingStatus.loading,
    this.filteredPlayers = const [],
    this.allPlayers = const [],
    this.playerCompetitions = const {},
    this.playingLevels = const [],
    this.clubs = const [],
    this.competitions = const [],
    this.teams = const [],
  });

  final LoadingStatus loadingStatus;
  final List<Player> filteredPlayers;
  final Map<Player, List<Competition>> playerCompetitions;

  final List<Player> allPlayers;
  final List<PlayingLevel> playingLevels;
  final List<Club> clubs;
  final List<Competition> competitions;
  final List<Team> teams;

  PlayerListState copyWith({
    LoadingStatus? loadingStatus,
    List<Player>? filteredPlayers,
    List<Player>? allPlayers,
    Map<Player, List<Competition>>? playerCompetitions,
    List<PlayingLevel>? playingLevels,
    List<Club>? clubs,
    List<Competition>? competitions,
    List<Team>? teams,
  }) {
    return PlayerListState(
      loadingStatus: loadingStatus ?? this.loadingStatus,
      filteredPlayers: filteredPlayers ?? this.filteredPlayers,
      allPlayers: allPlayers ?? this.allPlayers,
      playerCompetitions: playerCompetitions ?? this.playerCompetitions,
      playingLevels: playingLevels ?? this.playingLevels,
      clubs: clubs ?? this.clubs,
      competitions: competitions ?? this.competitions,
      teams: teams ?? this.teams,
    );
  }
}
