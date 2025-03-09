part of 'gymnasium_selection_cubit.dart';

class GymnasiumSelectionState extends CollectionQuerierState {
  GymnasiumSelectionState({
    this.loadingStatus = LoadingStatus.loading,
    this.gymnasium = const SelectionInput.pure(),
    this.courtsOfGym = const [],
    this.collections = const [],
  });

  @override
  final LoadingStatus loadingStatus;

  final SelectionInput<Gymnasium> gymnasium;
  final List<Court> courtsOfGym;

  @override
  List<List<Model>> collections;

  GymnasiumSelectionState copyWith({
    LoadingStatus? loadingStatus,
    SelectionInput<Gymnasium>? gymnasium,
    List<Court>? courtsOfGym,
    List<List<Model>>? collections,
  }) {
    return GymnasiumSelectionState(
      loadingStatus: loadingStatus ?? this.loadingStatus,
      gymnasium: gymnasium ?? this.gymnasium,
      courtsOfGym: courtsOfGym ?? this.courtsOfGym,
      collections: collections ?? this.collections,
    );
  }
}
