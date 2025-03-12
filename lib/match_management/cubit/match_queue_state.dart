part of 'match_queue_cubit.dart';

class MatchQueueState extends CollectionQuerierState {
  MatchQueueState({
    this.loadingStatus = LoadingStatus.loading,
    this.queuedRounds = const [],
    this.readyMatches = const [],
    this.runningMatches = const [],
    this.collections = const [],
  });

  @override
  final LoadingStatus loadingStatus;

  final List<ScheduledRound> queuedRounds;
  final List<MatchContext> readyMatches;
  final List<MatchContext> runningMatches;

  @override
  final List<List<Model>> collections;

  int get playerRestTime =>
      getCollection<TournamentEvent>().first.playerRestTime;
  QueueMode get queueMode => getCollection<TournamentEvent>().first.queueMode;

  MatchQueueState copyWith({
    LoadingStatus? loadingStatus,
    List<ScheduledRound>? queuedRounds,
    List<MatchContext>? readyMatches,
    List<MatchContext>? runningMatches,
    List<List<Model>>? collections,
  }) {
    return MatchQueueState(
      loadingStatus: loadingStatus ?? this.loadingStatus,
      queuedRounds: queuedRounds ?? this.queuedRounds,
      readyMatches: readyMatches ?? this.readyMatches,
      runningMatches: runningMatches ?? this.runningMatches,
      collections: collections ?? this.collections,
    );
  }
}
