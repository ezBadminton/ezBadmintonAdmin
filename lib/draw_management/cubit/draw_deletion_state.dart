part of 'draw_deletion_cubit.dart';

class DrawDeletionState {
  DrawDeletionState({
    required this.competition,
    this.formStatus = FormzSubmissionStatus.initial,
  });

  final Competition competition;

  final FormzSubmissionStatus formStatus;

  DrawDeletionState copyWith({
    Competition? competition,
    FormzSubmissionStatus? formStatus,
  }) {
    return DrawDeletionState(
      competition: competition ?? this.competition,
      formStatus: formStatus ?? this.formStatus,
    );
  }
}
