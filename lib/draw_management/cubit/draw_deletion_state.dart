part of 'draw_deletion_cubit.dart';

class DrawDeletionState {
  DrawDeletionState({
    this.formStatus = FormzSubmissionStatus.initial,
  });

  final FormzSubmissionStatus formStatus;

  DrawDeletionState copyWith({
    FormzSubmissionStatus? formStatus,
  }) {
    return DrawDeletionState(
      formStatus: formStatus ?? this.formStatus,
    );
  }
}
