// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'competition_selection_cubit.dart';

class CompetitionSelectionState extends CollectionQuerierState {
  CompetitionSelectionState({
    this.loadingStatus = LoadingStatus.loading,
    this.selectedCompetition = const SelectionInput.pure(value: null),
    this.selectableCompetitions = const [],
    this.collections = const [],
  });

  @override
  final LoadingStatus loadingStatus;

  final SelectionInput<Competition> selectedCompetition;

  final List<Competition> selectableCompetitions;

  @override
  final List<List<Model>> collections;

  CompetitionSelectionState copyWith({
    LoadingStatus? loadingStatus,
    SelectionInput<Competition>? selectedCompetition,
    List<Competition>? selectableCompetitions,
    List<List<Model>>? collections,
  }) {
    return CompetitionSelectionState(
      loadingStatus: loadingStatus ?? this.loadingStatus,
      selectedCompetition: selectedCompetition ?? this.selectedCompetition,
      selectableCompetitions:
          selectableCompetitions ?? this.selectableCompetitions,
      collections: collections ?? this.collections,
    );
  }
}
