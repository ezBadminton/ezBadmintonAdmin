// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'round_selection_cubit.dart';

class RoundSelectionState {
  RoundSelectionState({
    this.showRound = false,
    this.roundSelection = const SelectionInput.pure(emptyAllowed: true),
    this.waitingMatches = const [],
  });

  final bool showRound;
  final SelectionInput<ScheduledRound> roundSelection;
  final List<ScheduledMatch> waitingMatches;

  ScheduledRound? get round => roundSelection.value;

  RoundSelectionState copyWith({
    bool? showRound,
    SelectionInput<ScheduledRound>? roundSelection,
    List<ScheduledMatch>? waitingMatches,
  }) {
    return RoundSelectionState(
      showRound: showRound ?? this.showRound,
      roundSelection: roundSelection ?? this.roundSelection,
      waitingMatches: waitingMatches ?? this.waitingMatches,
    );
  }
}
