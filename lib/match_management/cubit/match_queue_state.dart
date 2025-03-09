part of 'match_queue_cubit.dart';

class MatchQueueState extends CollectionQuerierState {
  MatchQueueState({
    this.loadingStatus = LoadingStatus.loading,
    this.schedule,
    this.matchDataMap = const {},
    this.collections = const [],
  });

  @override
  final LoadingStatus loadingStatus;

  final Schedule? schedule;

  final Map<TournamentMatch, ScheduledMatchContext> matchDataMap;

  @override
  final List<List<Model>> collections;

  int get playerRestTime =>
      getCollection<TournamentEvent>().first.playerRestTime;
  QueueMode get queueMode => getCollection<TournamentEvent>().first.queueMode;

  MatchQueueState copyWith({
    LoadingStatus? loadingStatus,
    Schedule? schedule,
    Map<TournamentMatch, ScheduledMatchContext>? matchDataMap,
    List<List<Model>>? collections,
  }) {
    return MatchQueueState(
      loadingStatus: loadingStatus ?? this.loadingStatus,
      schedule: schedule ?? this.schedule,
      matchDataMap: matchDataMap ?? this.matchDataMap,
      collections: collections ?? this.collections,
    );
  }
}
