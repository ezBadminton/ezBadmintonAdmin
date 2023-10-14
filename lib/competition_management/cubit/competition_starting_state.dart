part of 'competition_starting_cubit.dart';

class CompetitionStartingState implements DialogState {
  CompetitionStartingState({
    this.formStatus = FormzSubmissionStatus.initial,
    this.selectedCompetitions = const [],
    this.dialog = const CubitDialog(),
    this.selectionIsStartable = false,
  });

  final FormzSubmissionStatus formStatus;

  final List<Competition> selectedCompetitions;

  @override
  final CubitDialog dialog;

  final bool selectionIsStartable;

  CompetitionStartingState copyWith({
    FormzSubmissionStatus? formStatus,
    List<Competition>? selectedCompetitions,
    CubitDialog? dialog,
    bool? selectionIsStartable,
  }) {
    return CompetitionStartingState(
      formStatus: formStatus ?? this.formStatus,
      selectedCompetitions: selectedCompetitions ?? this.selectedCompetitions,
      dialog: dialog ?? this.dialog,
      selectionIsStartable: selectionIsStartable ?? this.selectionIsStartable,
    );
  }
}
