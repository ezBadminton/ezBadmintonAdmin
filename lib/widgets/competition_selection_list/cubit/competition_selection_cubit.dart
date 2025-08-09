import 'package:collection/collection.dart';
import 'package:ez_badminton_admin_app/competition_management/competition_sorter/comparators/competition_comparator.dart';
import 'package:ez_badminton_admin_app/predicate_filter/predicate/filter_predicate.dart';
import 'package:model_repository/model_repository.dart';
import 'package:ez_badminton_admin_app/collection_queries/collection_querier.dart';
import 'package:ez_badminton_admin_app/input_models/models.dart';
import 'package:ez_badminton_admin_app/widgets/loading_screen/loading_screen.dart';

part 'competition_selection_state.dart';

class CompetitionSelectionCubit
    extends CollectionQuerierCubit<CompetitionSelectionState> {
  CompetitionSelectionCubit({
    required ModelStore<Competition> competitionStore,
    required Predicate? filterPredicate,
  })  : _filterPredicate = filterPredicate,
        super(
          modelStores: [competitionStore],
          CompetitionSelectionState(),
        ) {
    subscribeToCollectionUpdates(
      competitionStore,
      _onCompetitionCollectionUpdate,
    );
  }

  Predicate? _filterPredicate;

  final competitionComparator = CompetitionComparator();

  @override
  void onCollectionUpdate(
    List<List<Model>> collections,
    CollectionUpdateEvent<Model>? updateEvent,
  ) {
    CompetitionSelectionState updatedState = state.copyWith(
      collections: collections,
      loadingStatus: LoadingStatus.done,
    );

    List<Competition> sortedCompetitions =
        updatedState.getCollection<Competition>().sorted(
              competitionComparator.comparator,
            );
    updatedState.overrideCollection(sortedCompetitions);

    List<Competition> selectable = _getSelectableCompetitions(
      sortedCompetitions,
    );
    updatedState = updatedState.copyWith(
      selectableCompetitions: selectable,
    );

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

  /// Set [filter] to null for no filtering
  void filterChanged(Predicate? filter) {
    _filterPredicate = filter;

    List<Competition> selectable = _getSelectableCompetitions(
      state.getCollection<Competition>(),
    );
    var updatedState = state.copyWith(
      selectableCompetitions: selectable,
    );

    if (!selectable.contains(state.selectedCompetition.value)) {
      updatedState = updatedState.copyWith(
        selectedCompetition: SelectionInput.dirty(value: null),
      );
    }

    emit(updatedState);
  }

  void _onCompetitionCollectionUpdate(
    CollectionUpdateEvent<Competition>? event,
  ) {
    if (event == null || event.model != state.selectedCompetition.value) {
      return;
    }

    switch (event.updateType) {
      case UpdateType.update:
        emit(state.copyWith(
          selectedCompetition: SelectionInput.dirty(
            value: event.model,
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

  List<Competition> _getSelectableCompetitions(List<Competition> competitions) {
    if (_filterPredicate != null) {
      return competitions.where(_filterPredicate!).toList();
    } else {
      return competitions;
    }
  }
}
