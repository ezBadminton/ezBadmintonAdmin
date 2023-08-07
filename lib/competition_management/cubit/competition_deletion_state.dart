part of 'competition_deletion_cubit.dart';

class CompetitionDeletionState implements DialogState {
  CompetitionDeletionState({
    this.formStatus = FormzSubmissionStatus.initial,
    this.dialog = const CubitDialog(),
    this.selectedCompetitions = const [],
  });

  final FormzSubmissionStatus formStatus;

  @override
  final CubitDialog dialog;

  final List<Competition> selectedCompetitions;

  CompetitionDeletionState copyWith({
    FormzSubmissionStatus? formStatus,
    List<Competition>? selectedCompetitions,
    CubitDialog? dialog,
  }) {
    return CompetitionDeletionState(
      formStatus: formStatus ?? this.formStatus,
      dialog: dialog ?? this.dialog,
      selectedCompetitions: selectedCompetitions ?? this.selectedCompetitions,
    );
  }
}
