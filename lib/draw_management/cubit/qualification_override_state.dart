part of 'qualification_override_cubit.dart';

class QualificationOverrideState {
  QualificationOverrideState({
    this.formStatus = FormzSubmissionStatus.initial,
  });

  final FormzSubmissionStatus formStatus;

  QualificationOverrideState copyWith({
    FormzSubmissionStatus? formStatus,
  }) {
    return QualificationOverrideState(
      formStatus: formStatus ?? this.formStatus,
    );
  }
}
