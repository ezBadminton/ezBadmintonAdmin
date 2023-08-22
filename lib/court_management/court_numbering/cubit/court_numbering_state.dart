part of 'court_numbering_cubit.dart';

class CourtNumberingState implements DialogState {
  CourtNumberingState({
    this.formStatus = FormzSubmissionStatus.initial,
    this.dialog = const CubitDialog(),
  });

  final FormzSubmissionStatus formStatus;
  @override
  final CubitDialog dialog;

  CourtNumberingState copyWith({
    FormzSubmissionStatus? formStatus,
    CubitDialog? dialog,
  }) {
    return CourtNumberingState(
      formStatus: formStatus ?? this.formStatus,
      dialog: dialog ?? this.dialog,
    );
  }
}
