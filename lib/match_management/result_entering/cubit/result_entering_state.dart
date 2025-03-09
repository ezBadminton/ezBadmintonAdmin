part of 'result_entering_cubit.dart';

class ResultEnteringState {
  const ResultEnteringState({
    this.formStatus = FormzSubmissionStatus.initial,
    SelectionInput<int> winningParticipantIndex =
        const SelectionInput<int>.dirty(),
  }) : _winningParticipantIndex = winningParticipantIndex;

  final FormzSubmissionStatus formStatus;

  final SelectionInput<int> _winningParticipantIndex;
  int? get winningParticipantIndex => _winningParticipantIndex.value;

  ResultEnteringState copyWith({
    FormzSubmissionStatus? formStatus,
    SelectionInput<int>? winningParticipantIndex,
  }) {
    return ResultEnteringState(
      formStatus: formStatus ?? this.formStatus,
      winningParticipantIndex:
          winningParticipantIndex ?? _winningParticipantIndex,
    );
  }
}
