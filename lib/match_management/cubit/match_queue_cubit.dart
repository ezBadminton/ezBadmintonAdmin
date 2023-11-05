import 'dart:async';

import 'package:collection/collection.dart';
import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/badminton_tournament_ops/badminton_match.dart';
import 'package:ez_badminton_admin_app/badminton_tournament_ops/cubit/tournament_progress_cubit.dart';
import 'package:ez_badminton_admin_app/collection_queries/collection_querier.dart';
import 'package:ez_badminton_admin_app/match_management/cubit/mixins/match_court_assignment_query.dart';
import 'package:ez_badminton_admin_app/match_management/match_schedule/match_schedule.dart';
import 'package:ez_badminton_admin_app/widgets/loading_screen/loading_screen.dart';

part 'match_queue_state.dart';

class MatchQueueCubit extends CollectionFetcherCubit<MatchQueueState>
    with MatchCourtAssignmentQuery {
  MatchQueueCubit({
    required this.scheduler,
    required CollectionRepository<Tournament> tournamentRepository,
    required CollectionRepository<MatchData> matchDataRepository,
  }) : super(
          collectionRepositories: [
            tournamentRepository,
            matchDataRepository,
          ],
          MatchQueueState(),
        ) {
    loadCollections();
    subscribeToCollectionUpdates(
      tournamentRepository,
      (_) => loadCollections(),
    );
  }

  final MatchScheduler scheduler;

  Timer? _restTimer;

  void loadCollections() {
    if (state.loadingStatus != LoadingStatus.loading) {
      emit(state.copyWith(loadingStatus: LoadingStatus.loading));
    }
    fetchCollectionsAndUpdateState(
      [
        collectionFetcher<Tournament>(),
      ],
      onSuccess: (updatedState) {
        updatedState = updatedState.copyWith(loadingStatus: LoadingStatus.done);
        _emit(updatedState);
      },
      onFailure: () {
        emit(state.copyWith(loadingStatus: LoadingStatus.failed));
      },
    );
  }

  void tournamentChanged(TournamentProgressState progressState) {
    if (state.progressState == progressState) {
      return;
    }

    MatchQueueState newState = state.copyWith(
      progressState: progressState,
    );

    _emit(newState);
  }

  void _emit(MatchQueueState state) {
    if (state.progressState == null || state.collections.isEmpty) {
      emit(state);
      return;
    }

    MatchSchedule updatedSchedule =
        scheduler(state.progressState!, state.playerRestTime);

    _scheduleRestTimeUpdate(updatedSchedule.restingDeadlines);

    MatchQueueState newState = state.copyWith(
      matchSchedule: updatedSchedule,
    );

    if (state.queueMode == QueueMode.auto) {
      _callOutNextMatch(newState);
    }

    emit(newState);
  }

  void _callOutNextMatch(MatchQueueState queueState) async {
    Court? nextCourt = queueState.progressState!.openCourts.firstOrNull;
    BadmintonMatch? nextMatch =
        queueState.schedule[MatchWaitingStatus.waitingForCourt]?.firstOrNull;

    if (nextCourt == null || nextMatch == null) {
      return;
    }

    MatchData matchData = nextMatch.matchData!;

    submitMatchCourtAssignment(matchData, nextCourt);
  }

  void _scheduleRestTimeUpdate(Map<Player, DateTime> restingDeadlines) {
    if (_restTimer != null) {
      _restTimer!.cancel();
      _restTimer = null;
    }

    if (restingDeadlines.isEmpty) {
      return;
    }

    DateTime nextRestDeadline = restingDeadlines.values
        .reduce((value, element) => element.isBefore(value) ? element : value);

    DateTime now = DateTime.now().toUtc();
    Duration restDuration = nextRestDeadline.difference(now);

    _restTimer = Timer(restDuration, _onRestTimeUpdate);
  }

  void _onRestTimeUpdate() {
    _emit(state);
  }
}
