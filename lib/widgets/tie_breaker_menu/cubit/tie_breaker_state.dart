part of 'tie_breaker_cubit.dart';

class TieBreakerState {
  TieBreakerState({
    required this.tie,
    this.formStatus = FormzSubmissionStatus.initial,
  });

  final FormzSubmissionStatus formStatus;

  final List<Team> tie;

  TieBreakerState copyWith({
    List<Team>? tie,
    FormzSubmissionStatus? formStatus,
  }) {
    return TieBreakerState(
      tie: tie ?? this.tie,
      formStatus: formStatus ?? this.formStatus,
    );
  }
}
