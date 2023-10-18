import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/badminton_tournament_ops/badminton_match.dart';
import 'package:ez_badminton_admin_app/badminton_tournament_ops/badminton_tournament_modes.dart';
import 'package:ez_badminton_admin_app/badminton_tournament_ops/tournament_mode_hydration.dart';
import 'package:ez_badminton_admin_app/collection_queries/collection_querier.dart';
import 'package:ez_badminton_admin_app/widgets/loading_screen/loading_screen.dart';
import 'package:formz/formz.dart';

part 'match_queue_state.dart';

class MatchQueueCubit extends CollectionFetcherCubit<MatchQueueState> {
  MatchQueueCubit({
    required CollectionRepository<Competition> competitionRepository,
  }) : super(
          collectionRepositories: [
            competitionRepository,
          ],
          MatchQueueState(),
        ) {
    loadCollections();
    subscribeToCollectionUpdates(
      competitionRepository,
      (_) => loadCollections(),
    );
  }

  void loadCollections() {
    if (state.loadingStatus != LoadingStatus.loading) {
      emit(state.copyWith(loadingStatus: LoadingStatus.loading));
    }
    fetchCollectionsAndUpdateState(
      [
        collectionFetcher<Competition>(),
      ],
      onSuccess: (updatedState) {
        updatedState = _createMatchQueue(updatedState);
        emit(updatedState.copyWith(loadingStatus: LoadingStatus.done));
      },
      onFailure: () {
        emit(state.copyWith(loadingStatus: LoadingStatus.failed));
      },
    );
  }

  MatchQueueState _createMatchQueue(MatchQueueState state) {
    List<Competition> runningCompetitions = state
        .getCollection<Competition>()
        .where((c) => c.matches.isNotEmpty)
        .toList();

    List<BadmintonMatch> matches = runningCompetitions.expand((c) {
      BadmintonTournamentMode tournamentMode = createTournamentMode(c);
      hydrateTournament(tournamentMode, c.matches);

      return tournamentMode.matches
          .where((match) => !match.isBye)
          .map((match) => match..competition = c);
    }).toList();

    Map<MatchWaitingStatus, List<BadmintonMatch>> waitList = {
      MatchWaitingStatus.waitingForCourt:
          matches.where((m) => m.isPlayable && m.court == null).toList(),
      MatchWaitingStatus.waitingForProgress:
          matches.where((m) => !m.isPlayable).toList(),
    };

    List<BadmintonMatch> calloutWaitList =
        matches.where((m) => m.startTime == null && m.court != null).toList();

    List<BadmintonMatch> inProgressList =
        matches.where((m) => m.startTime != null && m.score == null).toList();

    return state.copyWith(
      waitList: waitList,
      calloutWaitList: calloutWaitList,
      inProgressList: inProgressList,
    );
  }
}
