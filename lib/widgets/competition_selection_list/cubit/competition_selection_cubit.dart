import 'package:collection/collection.dart';
import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/collection_queries/collection_querier.dart';
import 'package:ez_badminton_admin_app/utils/sorting.dart';
import 'package:ez_badminton_admin_app/input_models/models.dart';
import 'package:ez_badminton_admin_app/widgets/loading_screen/loading_screen.dart';

part 'competition_selection_state.dart';

class CompetitionSelectionCubit
    extends CollectionQuerierCubit<CompetitionSelectionState> {
  CompetitionSelectionCubit({
    required CollectionRepository<Competition> competitionRepository,
  }) : super(
          collectionRepositories: [competitionRepository],
          CompetitionSelectionState(),
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
    CompetitionSelectionState updatedState = state.copyWith(
      collections: collections,
      loadingStatus: LoadingStatus.done,
    );

    List<Competition> sortedCompetitions =
        updatedState.getCollection<Competition>().sorted(compareCompetitions);

    updatedState.overrideCollection(sortedCompetitions);

    emit(updatedState);
  }

  void competitionToggled(Competition competition) {
    Competition? selectedCompetition = competition;
    if (state.selectedCompetition.value == competition) {
      selectedCompetition = null;
    }

    competitionSelected(selectedCompetition);
  }

  void competitionSelected(Competition? selectedCompetition) {
    emit(state.copyWith(
      selectedCompetition: SelectionInput.dirty(value: selectedCompetition),
    ));
  }

  void _onCompetitionCollectionUpdate(
    List<CollectionUpdateEvent<Competition>> events,
  ) {
    CollectionUpdateEvent<Competition>? selectionUpdate =
        events.reversed.firstWhereOrNull(
      (e) => e.model.id == state.selectedCompetition.value?.id,
    );

    if (selectionUpdate == null) {
      return;
    }

    switch (selectionUpdate.updateType) {
      case UpdateType.update:
        emit(state.copyWith(
          selectedCompetition: SelectionInput.dirty(
            value: selectionUpdate.model,
          ),
        ));
        break;
      case UpdateType.delete:
        emit(state.copyWith(
          selectedCompetition: const SelectionInput.dirty(value: null),
        ));
        break;
      case UpdateType.create:
        break;
    }
  }
}
