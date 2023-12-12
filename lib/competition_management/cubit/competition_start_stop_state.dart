part of 'competition_start_stop_cubit.dart';

class CompetitionStartStopState implements DialogState {
  CompetitionStartStopState({
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

  CompetitionStartStopState copyWith({
    FormzSubmissionStatus? formStatus,
    List<Competition>? selectedCompetitions,
    CubitDialog? dialog,
    bool? selectionIsStartable,
  }) {
    return CompetitionStartStopState(
      formStatus: formStatus ?? this.formStatus,
      selectedCompetitions: selectedCompetitions ?? this.selectedCompetitions,
      dialog: dialog ?? this.dialog,
      selectionIsStartable: selectionIsStartable ?? this.selectionIsStartable,
    );
  }
}
