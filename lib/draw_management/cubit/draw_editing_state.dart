part of 'draw_editing_cubit.dart';

class DrawEditingState {
  DrawEditingState({
    this.formStatus = FormzSubmissionStatus.initial,
    required this.competition,
  });

  final FormzSubmissionStatus formStatus;
  final Competition competition;

  DrawEditingState copyWith({
    FormzSubmissionStatus? formStatus,
    Competition? competition,
  }) {
    return DrawEditingState(
      formStatus: formStatus ?? this.formStatus,
      competition: competition ?? this.competition,
    );
  }
}
