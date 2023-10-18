part of 'match_queue_cubit.dart';

class MatchQueueState extends CollectionFetcherState<MatchQueueState> {
  MatchQueueState({
    this.loadingStatus = LoadingStatus.loading,
    this.formStatus = FormzSubmissionStatus.initial,
    this.waitList = const {},
    this.calloutWaitList = const [],
    this.inProgressList = const [],
    super.collections = const {},
  });

  final LoadingStatus loadingStatus;
  final FormzSubmissionStatus formStatus;

  final Map<MatchWaitingStatus, List<BadmintonMatch>> waitList;
  final List<BadmintonMatch> calloutWaitList;
  final List<BadmintonMatch> inProgressList;

  MatchQueueState copyWith({
    LoadingStatus? loadingStatus,
    FormzSubmissionStatus? formStatus,
    Map<Type, List<Model>>? collections,
    Map<MatchWaitingStatus, List<BadmintonMatch>>? waitList,
    List<BadmintonMatch>? calloutWaitList,
    List<BadmintonMatch>? inProgressList,
  }) {
    return MatchQueueState(
      loadingStatus: loadingStatus ?? this.loadingStatus,
      formStatus: formStatus ?? this.formStatus,
      waitList: waitList ?? this.waitList,
      calloutWaitList: calloutWaitList ?? this.calloutWaitList,
      inProgressList: inProgressList ?? this.inProgressList,
      collections: collections ?? this.collections,
    );
  }
}

enum MatchWaitingStatus {
  waitingForCourt,
  waitingForPlayerRest,
  waitingForProgress,
}
