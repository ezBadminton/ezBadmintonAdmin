part of 'match_queue_cubit.dart';

class MatchQueueState {
  MatchQueueState({
    this.waitList = const {},
    this.calloutWaitList = const [],
    this.inProgressList = const [],
  });

  final Map<MatchWaitingStatus, List<BadmintonMatch>> waitList;
  final List<BadmintonMatch> calloutWaitList;
  final List<BadmintonMatch> inProgressList;

  MatchQueueState copyWith({
    Map<MatchWaitingStatus, List<BadmintonMatch>>? waitList,
    List<BadmintonMatch>? calloutWaitList,
    List<BadmintonMatch>? inProgressList,
  }) {
    return MatchQueueState(
      waitList: waitList ?? this.waitList,
      calloutWaitList: calloutWaitList ?? this.calloutWaitList,
      inProgressList: inProgressList ?? this.inProgressList,
    );
  }
}

enum MatchWaitingStatus {
  waitingForCourt,
  waitingForPlayer,
  waitingForProgress,
}
