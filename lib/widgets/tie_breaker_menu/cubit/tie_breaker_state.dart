part of 'tie_breaker_cubit.dart';

class TieBreakerState {
  TieBreakerState({
    SelectionInput<TieBreaker> tieBreaker =
        const SelectionInput.pure(emptyAllowed: true),
    this.formStatus = FormzSubmissionStatus.initial,
  }) : _tieBreaker = tieBreaker;

  final FormzSubmissionStatus formStatus;

  final SelectionInput<TieBreaker> _tieBreaker;
  TieBreaker get tieBreaker => _tieBreaker.value!;
  List<Team> get tiedTeams => _tieBreaker.value!.tieBreakerRanking;
  bool get isDirty => !_tieBreaker.isPure;

  TieBreakerState copyWith({
    SelectionInput<TieBreaker>? tieBreaker,
    FormzSubmissionStatus? formStatus,
  }) {
    return TieBreakerState(
      tieBreaker: tieBreaker ?? _tieBreaker,
      formStatus: formStatus ?? this.formStatus,
    );
  }
}
