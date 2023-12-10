part of 'competition_deletion_cubit.dart';

class CompetitionDeletionState implements DialogState {
  CompetitionDeletionState({
    this.formStatus = FormzSubmissionStatus.initial,
    this.dialog = const CubitDialog(),
    this.isSelectionDeletable = false,
    this.selectedCompetitions = const [],
  });

  final FormzSubmissionStatus formStatus;

  final bool isSelectionDeletable;

  @override
  final CubitDialog dialog;

  final List<Competition> selectedCompetitions;

  CompetitionDeletionState copyWith({
    FormzSubmissionStatus? formStatus,
    bool? isSelectionDeletable,
    List<Competition>? selectedCompetitions,
    CubitDialog? dialog,
  }) {
    return CompetitionDeletionState(
      formStatus: formStatus ?? this.formStatus,
      isSelectionDeletable: isSelectionDeletable ?? this.isSelectionDeletable,
      dialog: dialog ?? this.dialog,
      selectedCompetitions: selectedCompetitions ?? this.selectedCompetitions,
    );
  }
}
