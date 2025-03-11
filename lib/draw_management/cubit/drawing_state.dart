part of 'drawing_cubit.dart';

class DrawingState implements DialogState {
  DrawingState({
    this.formStatus = FormzSubmissionStatus.initial,
    this.dialog = const CubitDialog(),
  });

  final FormzSubmissionStatus formStatus;

  @override
  final CubitDialog dialog;

  DrawingState copyWith({
    FormzSubmissionStatus? formStatus,
    CubitDialog? dialog,
  }) {
    return DrawingState(
      formStatus: formStatus ?? this.formStatus,
      dialog: dialog ?? this.dialog,
    );
  }
}
