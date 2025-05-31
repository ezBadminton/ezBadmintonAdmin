import 'package:model_repository/model_repository.dart';
import 'package:ez_badminton_admin_app/collection_queries/collection_querier.dart';
import 'package:ez_badminton_admin_app/widgets/loading_screen/loading_screen.dart';

part 'model_selection_state.dart';

class ModelSelectionCubit<M extends Model>
    extends CollectionQuerierCubit<ModelSelectionState<M>> {
  ModelSelectionCubit({
    required ModelStore<M> store,
  }) : super(
          modelStores: [store],
          ModelSelectionState<M>(),
        ) {
    subscribeToCollectionUpdates(
      store,
      _onCollectionUpdate,
    );
  }

  @override
  void onCollectionUpdate(
    List<List<Model>> collections,
    CollectionUpdateEvent<Model>? updateEvent,
  ) {
    if (updateEvent == null) {
      List<M> models = collections.firstWhere((c) => c is List<M>) as List<M>;
      ModelSelectionState<M> updatedState = state.copyWith(
        displayModels: models,
        loadingStatus: LoadingStatus.done,
      );

      emit(updatedState);
    }
  }

  void displayModelsChanges(List<M> displayModels) {
    ModelSelectionState<M> updatedState =
        state.copyWith(displayModels: displayModels);
    updatedState = _updateSelection(updatedState);
    emit(updatedState);
  }

  void allModelsToggled() {
    switch (state.selectionTristate) {
      case true:
        emit(state.copyWith(selectedModels: []));
        break;
      case false:
      case null:
        emit(state.copyWith(selectedModels: state.displayModels));
        break;
    }
  }

  void modelToggled(M model) {
    List<M> selected = List.of(state.selectedModels);
    if (selected.contains(model)) {
      selected.remove(model);
    } else {
      selected.add(model);
    }
    emit(state.copyWith(selectedModels: selected));
  }

  // Remove selected items that are no longer in the display list
  ModelSelectionState<M> _updateSelection(
    ModelSelectionState<M> updatedState,
  ) {
    List<M> updatedSelection = List.of(updatedState.selectedModels)
        .where(
          (m) => updatedState.displayModels.contains(m),
        )
        .toList();
    return updatedState.copyWith(selectedModels: updatedSelection);
  }

  void _onCollectionUpdate(
    CollectionUpdateEvent<M> event,
  ) {
    List<M> selected = List.of(state.selectedModels);

    if (!selected.contains(event.model)) {
      return;
    }

    selected.removeWhere((c) => c.id == event.model.id);
    selected.add(event.model);

    emit(state.copyWith(selectedModels: selected));
  }
}
