part of 'model_selection_cubit.dart';

class ModelSelectionState<M extends Model> extends CollectionQuerierState {
  ModelSelectionState({
    this.loadingStatus = LoadingStatus.loading,
    this.selectedModels = const [],
    this.displayModels = const [],
    this.collections = const [],
  }) : selectionTristate = _getSelectionTristate(
          selectedModels,
          displayModels,
        );

  @override
  final LoadingStatus loadingStatus;

  final List<M> selectedModels;
  final List<M> displayModels;

  final bool? selectionTristate;

  @override
  final List<List<Model>> collections;

  ModelSelectionState<M> copyWith({
    LoadingStatus? loadingStatus,
    List<M>? selectedModels,
    List<M>? displayModels,
    List<List<Model>>? collections,
  }) {
    return ModelSelectionState(
      loadingStatus: loadingStatus ?? this.loadingStatus,
      selectedModels: selectedModels ?? this.selectedModels,
      displayModels: displayModels ?? this.displayModels,
      collections: collections ?? this.collections,
    );
  }

  static bool? _getSelectionTristate<M extends Model>(
    List<M> selectedModels,
    List<M> displayModels,
  ) {
    if (displayModels.isEmpty || selectedModels.isEmpty) {
      return false;
    }

    if (selectedModels.length < displayModels.length) {
      return null;
    }

    return true;
  }
}
