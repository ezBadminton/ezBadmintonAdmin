import 'package:ez_badminton_admin_app/collection_queries/collection_querier.dart';
import 'package:ez_badminton_admin_app/utils/list_extension/list_extension.dart';
import 'package:ez_badminton_admin_app/widgets/loading_screen/loading_screen.dart';
import 'package:model_repository/model_repository.dart';

part 'match_context_state.dart';

class MatchContextCubit extends CollectionQuerierCubit<MatchContextState> {
  MatchContextCubit({
    TournamentMatch? match,
    ScheduledMatch? scheduledMatch,
    required ModelStore<TournamentMatch> tournamentMatchStore,
    required ModelStore<ScheduledMatch> scheduledMatchStore,
  }) : super(
          modelStores: [
            tournamentMatchStore,
            scheduledMatchStore,
          ],
          MatchContextState(
            match: match,
            scheduledMatch: scheduledMatch,
          ),
        ) {
    subscribeToCollectionUpdates(tournamentMatchStore, _onMatchUpdate);
    subscribeToCollectionUpdates(scheduledMatchStore, _onScheduledMatchUpdate);
  }

  @override
  void onCollectionUpdate(
    List<List<Model>> collections,
    List<CollectionUpdateEvent<Model>>? updateEvents,
  ) {
    if (updateEvents == null) {
      emit(state.copyWith(
        loadingStatus: LoadingStatus.done,
        collections: collections,
      ));
    }
  }

  void _onMatchUpdate(List<CollectionUpdateEvent<TournamentMatch>> events) {
    TournamentMatch? updatedMatch = events.latestVersion(state._match!);
    if (updatedMatch != null) {
      emit(state.copyWith(match: updatedMatch));
    }
  }

  void _onScheduledMatchUpdate(
    List<CollectionUpdateEvent<ScheduledMatch>> events,
  ) {
    ScheduledMatch? updatedMatch = events.latestVersion(state._scheduledMatch!);
    if (updatedMatch != null) {
      emit(state.copyWith(scheduledMatch: updatedMatch));
    }
  }
}
