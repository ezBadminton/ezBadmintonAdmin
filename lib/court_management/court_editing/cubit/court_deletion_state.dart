// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'court_deletion_cubit.dart';

class CourtDeletionState {
  CourtDeletionState({
    this.formStatus = FormzSubmissionStatus.initial,
    required this.court,
  });

  final FormzSubmissionStatus formStatus;
  final Court court;

  CourtDeletionState copyWith({
    FormzSubmissionStatus? formStatus,
    Court? court,
  }) {
    return CourtDeletionState(
      formStatus: formStatus ?? this.formStatus,
      court: court ?? this.court,
    );
  }
}
