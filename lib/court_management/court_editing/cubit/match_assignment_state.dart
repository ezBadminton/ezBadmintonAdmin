part of 'match_assignment_cubit.dart';

class MatchAssignmentState {
  MatchAssignmentState({
    required this.court,
    this.formStatus = FormzSubmissionStatus.initial,
  });

  final Court court;

  final FormzSubmissionStatus formStatus;

  MatchAssignmentState copyWith({
    Court? court,
    FormzSubmissionStatus? formStatus,
  }) {
    return MatchAssignmentState(
      court: court ?? this.court,
      formStatus: formStatus ?? this.formStatus,
    );
  }
}
