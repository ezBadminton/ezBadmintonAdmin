part of 'gymnasium_selection_cubit.dart';

class GymnasiumSelectionState
    extends CollectionFetcherState<GymnasiumSelectionState> {
  GymnasiumSelectionState({
    this.loadingStatus = LoadingStatus.loading,
    this.gymnasium = const SelectionInput.pure(),
    this.courtsOfGym = const [],
    super.collections = const {},
  });

  final LoadingStatus loadingStatus;

  final SelectionInput<Gymnasium> gymnasium;
  final List<Court> courtsOfGym;

  GymnasiumSelectionState copyWith({
    LoadingStatus? loadingStatus,
    SelectionInput<Gymnasium>? gymnasium,
    List<Court>? courtsOfGym,
    Map<Type, List<Model>>? collections,
  }) {
    return GymnasiumSelectionState(
      loadingStatus: loadingStatus ?? this.loadingStatus,
      gymnasium: gymnasium ?? this.gymnasium,
      courtsOfGym: courtsOfGym ?? this.courtsOfGym,
      collections: collections ?? this.collections,
    );
  }
}
