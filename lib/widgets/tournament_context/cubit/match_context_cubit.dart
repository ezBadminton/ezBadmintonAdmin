import 'package:ez_badminton_admin_app/collection_queries/collection_querier.dart';
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
    CollectionUpdateEvent<Model>? updateEvent,
  ) {
    if (updateEvent == null) {
      emit(state.copyWith(
        loadingStatus: LoadingStatus.done,
        collections: collections,
      ));
    }
  }

  void _onMatchUpdate(CollectionUpdateEvent<TournamentMatch> event) {
    if (event.model == state._match) {
      emit(state.copyWith(match: event.model));
    }
  }

  void _onScheduledMatchUpdate(CollectionUpdateEvent<ScheduledMatch> event) {
    if (event.model == state._scheduledMatch) {
      emit(state.copyWith(scheduledMatch: event.model));
    }
  }
}
