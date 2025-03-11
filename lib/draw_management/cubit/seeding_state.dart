part of 'seeding_cubit.dart';

class SeedingState {
  SeedingState({
    this.formStatus = FormzSubmissionStatus.initial,
    required this.competition,
  });

  final FormzSubmissionStatus formStatus;
  final Competition competition;

  SeedingState copyWith({
    FormzSubmissionStatus? formStatus,
    Competition? competition,
  }) {
    return SeedingState(
      formStatus: formStatus ?? this.formStatus,
      competition: competition ?? this.competition,
    );
  }
}
