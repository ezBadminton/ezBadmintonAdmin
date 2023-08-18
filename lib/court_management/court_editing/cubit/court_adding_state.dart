part of 'court_adding_cubit.dart';

class CourtAddingState {
  CourtAddingState({
    this.formStatus = FormzSubmissionStatus.initial,
    required this.gymnasium,
  });

  final FormzSubmissionStatus formStatus;

  final Gymnasium gymnasium;

  CourtAddingState copyWith({
    FormzSubmissionStatus? formStatus,
    Gymnasium? gymnasium,
  }) {
    return CourtAddingState(
      formStatus: formStatus ?? this.formStatus,
      gymnasium: gymnasium ?? this.gymnasium,
    );
  }
}
