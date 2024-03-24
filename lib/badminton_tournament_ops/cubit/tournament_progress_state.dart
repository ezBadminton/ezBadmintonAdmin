part of 'tournament_progress_cubit.dart';

class TournamentProgressState extends CollectionQuerierState {
  TournamentProgressState({
    this.loadingStatus = LoadingStatus.loading,
    this.runningTournaments = const {},
    this.occupiedCourts = const {},
    this.openCourts = const [],
    this.playingPlayers = const {},
    this.lastPlayerMatches = const {},
    this.editableMatches = const [],
    this.collections = const [],
  });

  @override
  final LoadingStatus loadingStatus;

  final Map<Competition, BadmintonTournamentMode> runningTournaments;

  final Map<Court, BadmintonMatch> occupiedCourts;
  final List<Court> openCourts;

  final Map<Player, BadmintonMatch> playingPlayers;

  final Map<Player, DateTime> lastPlayerMatches;

  final List<BadmintonMatch> editableMatches;

  @override
  final List<List<Model>> collections;

  TournamentProgressState copyWith({
    LoadingStatus? loadingStatus,
    Map<Competition, BadmintonTournamentMode>? runningTournaments,
    Map<Court, BadmintonMatch>? occupiedCourts,
    List<Court>? openCourts,
    Map<Player, BadmintonMatch>? playingPlayers,
    Map<Player, DateTime>? lastPlayerMatches,
    List<BadmintonMatch>? editableMatches,
    List<List<Model>>? collections,
  }) {
    return TournamentProgressState(
      loadingStatus: loadingStatus ?? this.loadingStatus,
      runningTournaments: runningTournaments ?? this.runningTournaments,
      occupiedCourts: occupiedCourts ?? this.occupiedCourts,
      openCourts: openCourts ?? this.openCourts,
      playingPlayers: playingPlayers ?? this.playingPlayers,
      lastPlayerMatches: lastPlayerMatches ?? this.lastPlayerMatches,
      editableMatches: editableMatches ?? this.editableMatches,
      collections: collections ?? this.collections,
    );
  }
}
