part of 'match_queue_cubit.dart';

class MatchQueueState extends CollectionFetcherState<MatchQueueState> {
  MatchQueueState({
    this.loadingStatus = LoadingStatus.loading,
    this.progressState,
    this.waitList = const {},
    this.calloutWaitList = const [],
    this.inProgressList = const [],
    this.restingPlayers = const {},
    super.collections = const {},
  });

  final LoadingStatus loadingStatus;

  final TournamentProgressState? progressState;

  final Map<MatchWaitingStatus, List<BadmintonMatch>> waitList;
  final List<BadmintonMatch> calloutWaitList;
  final List<BadmintonMatch> inProgressList;

  final Map<Player, DateTime> restingPlayers;

  int get playerRestTime => getCollection<Tournament>().first.playerRestTime;

  MatchQueueState copyWith({
    LoadingStatus? loadingStatus,
    TournamentProgressState? progressState,
    Map<MatchWaitingStatus, List<BadmintonMatch>>? waitList,
    List<BadmintonMatch>? calloutWaitList,
    List<BadmintonMatch>? inProgressList,
    Map<Player, DateTime>? restingPlayers,
    Map<Type, List<Model>>? collections,
  }) {
    return MatchQueueState(
      loadingStatus: loadingStatus ?? this.loadingStatus,
      progressState: progressState ?? this.progressState,
      waitList: waitList ?? this.waitList,
      calloutWaitList: calloutWaitList ?? this.calloutWaitList,
      inProgressList: inProgressList ?? this.inProgressList,
      restingPlayers: restingPlayers ?? this.restingPlayers,
      collections: collections ?? this.collections,
    );
  }
}

enum MatchWaitingStatus {
  waitingForCourt,
  waitingForRest,
  waitingForPlayer,
  waitingForProgress,
}
