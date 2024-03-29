part of 'match_queue_cubit.dart';

class MatchQueueState extends CollectionQuerierState {
  MatchQueueState({
    this.loadingStatus = LoadingStatus.loading,
    this.progressState,
    this.matchSchedule,
    this.collections = const [],
  });

  @override
  final LoadingStatus loadingStatus;

  final TournamentProgressState? progressState;

  final MatchSchedule? matchSchedule;

  @override
  final List<List<Model>> collections;

  Map<MatchWaitingStatus, List<BadmintonMatch>> get schedule =>
      matchSchedule?.schedule ?? {};
  List<BadmintonMatch> get calloutWaitList =>
      matchSchedule?.calloutWaitList ?? [];
  List<BadmintonMatch> get inProgressList =>
      matchSchedule?.inProgressList ?? [];

  Map<Player, DateTime> get restingDeadlines =>
      matchSchedule?.restingDeadlines ?? {};

  int get playerRestTime => getCollection<Tournament>().first.playerRestTime;
  QueueMode get queueMode => getCollection<Tournament>().first.queueMode;

  MatchQueueState copyWith({
    LoadingStatus? loadingStatus,
    TournamentProgressState? progressState,
    MatchSchedule? matchSchedule,
    List<List<Model>>? collections,
  }) {
    return MatchQueueState(
      loadingStatus: loadingStatus ?? this.loadingStatus,
      progressState: progressState ?? this.progressState,
      matchSchedule: matchSchedule ?? this.matchSchedule,
      collections: collections ?? this.collections,
    );
  }
}
