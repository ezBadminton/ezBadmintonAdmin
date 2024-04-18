import 'package:collection/collection.dart';
import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/collection_queries/collection_querier.dart';
import 'package:ez_badminton_admin_app/utils/list_extension/list_extension.dart';
import 'package:ez_badminton_admin_app/utils/sorting.dart';
import 'package:ez_badminton_admin_app/widgets/loading_screen/loading_screen.dart';

part 'competition_multi_selection_state.dart';

class CompetitionMultiSelectionCubit
    extends CollectionQuerierCubit<CompetitionMultiSelectionState> {
  CompetitionMultiSelectionCubit({
    required CollectionRepository<Competition> competitionRepository,
  }) : super(
          collectionRepositories: [competitionRepository],
          const CompetitionMultiSelectionState(),
        ) {
    subscribeToCollectionUpdates(
      competitionRepository,
      _onCompetitionCollectionUpdate,
    );
  }

  @override
  void onCollectionUpdate(
    List<List<Model>> collections,
    List<CollectionUpdateEvent<Model>> updateEvents,
  ) {
    CompetitionMultiSelectionState updatedState = state.copyWith(
      collections: collections,
      loadingStatus: LoadingStatus.done,
    );

    List<Competition> sortedCompetitions =
        updatedState.getCollection<Competition>().sorted(compareCompetitions);

    updatedState.overrideCollection(sortedCompetitions);

    emit(updatedState);
  }

  void competitionToggled(Competition competition) {
    List<Competition> newSelected = List.of(state.selectedCompetitions);

    if (state.selectedCompetitions.contains(competition)) {
      newSelected.remove(competition);
    } else {
      newSelected.add(competition);
    }

    emit(state.copyWith(selectedCompetitions: newSelected));
  }

  void _onCompetitionCollectionUpdate(
    List<CollectionUpdateEvent<Competition>> events,
  ) {
    List<CollectionUpdateEvent<Competition>> updatedSelected = events.reversed
        .where(
          (e) => state.selectedCompetitions.contains(e.model),
        )
        .toList();

    if (updatedSelected.isEmpty) {
      return;
    }

    List<Competition> newSelected = List.of(state.selectedCompetitions);

    for (CollectionUpdateEvent<Competition> update in updatedSelected) {
      switch (update.updateType) {
        case UpdateType.update:
          newSelected.replaceModel(update.model.id, update.model);
          break;
        case UpdateType.delete:
          newSelected.remove(update.model);
          break;
        case UpdateType.create:
          break;
      }
    }

    emit(state.copyWith(selectedCompetitions: newSelected));
  }
}
