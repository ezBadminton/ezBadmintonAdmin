part of 'tournament_progress_cubit.dart';

class TournamentProgressState
    extends CollectionFetcherState<TournamentProgressState> {
  TournamentProgressState({
    this.loadingStatus = LoadingStatus.loading,
    this.runningTournaments = const {},
    this.occupiedCourts = const {},
    this.openCourts = const [],
    this.playingPlayers = const {},
    this.restingPlayers = const {},
    super.collections = const {},
  });

  final LoadingStatus loadingStatus;

  final Map<Competition, BadmintonTournamentMode> runningTournaments;

  final Map<Court, BadmintonMatch> occupiedCourts;
  final List<Court> openCourts;

  final Map<Player, BadmintonMatch> playingPlayers;

  final Map<Player, DateTime> restingPlayers;

  TournamentProgressState copyWith({
    LoadingStatus? loadingStatus,
    Map<Competition, BadmintonTournamentMode>? runningTournaments,
    Map<Court, BadmintonMatch>? occupiedCourts,
    List<Court>? openCourts,
    Map<Player, BadmintonMatch>? playingPlayers,
    Map<Player, DateTime>? restingPlayers,
    Map<Type, List<Model>>? collections,
  }) {
    return TournamentProgressState(
      loadingStatus: loadingStatus ?? this.loadingStatus,
      runningTournaments: runningTournaments ?? this.runningTournaments,
      occupiedCourts: occupiedCourts ?? this.occupiedCourts,
      openCourts: openCourts ?? this.openCourts,
      playingPlayers: playingPlayers ?? this.playingPlayers,
      restingPlayers: restingPlayers ?? this.restingPlayers,
      collections: collections ?? this.collections,
    );
  }
}
