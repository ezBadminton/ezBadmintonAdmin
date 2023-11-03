part of 'match_court_assignment_cubit.dart';

class MatchCourtAssignmentState {
  MatchCourtAssignmentState({
    this.formStatus = FormzSubmissionStatus.initial,
  });

  final FormzSubmissionStatus formStatus;

  MatchCourtAssignmentState copyWith({
    FormzSubmissionStatus? formStatus,
  }) {
    return MatchCourtAssignmentState(
      formStatus: formStatus ?? this.formStatus,
    );
  }
}
