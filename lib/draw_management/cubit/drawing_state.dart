part of 'drawing_cubit.dart';

class DrawingState implements DialogState {
  DrawingState({
    this.formStatus = FormzSubmissionStatus.initial,
    required this.competition,
    this.dialog = const CubitDialog(),
  });

  final FormzSubmissionStatus formStatus;

  final Competition competition;

  @override
  final CubitDialog dialog;

  DrawingState copyWith({
    FormzSubmissionStatus? formStatus,
    Competition? competition,
    CubitDialog? dialog,
  }) {
    return DrawingState(
      formStatus: formStatus ?? this.formStatus,
      competition: competition ?? this.competition,
      dialog: dialog ?? this.dialog,
    );
  }
}
