part of 'drawing_cubit.dart';

class DrawingState {
  DrawingState({
    this.formStatus = FormzSubmissionStatus.initial,
    required this.competition,
  });

  final FormzSubmissionStatus formStatus;

  final Competition competition;

  DrawingState copyWith({
    FormzSubmissionStatus? formStatus,
    Competition? competition,
  }) {
    return DrawingState(
      formStatus: formStatus ?? this.formStatus,
      competition: competition ?? this.competition,
    );
  }
}
