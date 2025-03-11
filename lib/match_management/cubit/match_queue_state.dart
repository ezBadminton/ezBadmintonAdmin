part of 'match_queue_cubit.dart';

class MatchQueueState extends CollectionQuerierState {
  MatchQueueState({
    this.loadingStatus = LoadingStatus.loading,
    this.schedule,
    this.collections = const [],
  });

  @override
  final LoadingStatus loadingStatus;

  final Schedule? schedule;

  @override
  final List<List<Model>> collections;

  int get playerRestTime =>
      getCollection<TournamentEvent>().first.playerRestTime;
  QueueMode get queueMode => getCollection<TournamentEvent>().first.queueMode;

  MatchQueueState copyWith({
    LoadingStatus? loadingStatus,
    Schedule? schedule,
    List<List<Model>>? collections,
  }) {
    return MatchQueueState(
      loadingStatus: loadingStatus ?? this.loadingStatus,
      schedule: schedule ?? this.schedule,
      collections: collections ?? this.collections,
    );
  }
}
