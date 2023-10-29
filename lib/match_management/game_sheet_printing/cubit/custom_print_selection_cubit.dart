import 'package:ez_badminton_admin_app/badminton_tournament_ops/badminton_match.dart';
import 'package:ez_badminton_admin_app/badminton_tournament_ops/cubit/tournament_progress_cubit.dart';
import 'package:ez_badminton_admin_app/input_models/list_input.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';

part 'custom_print_selection_state.dart';

class CustomPrintSelectionCubit extends Cubit<CustomPrintSelectionState> {
  CustomPrintSelectionCubit({
    required TournamentProgressState progressState,
    required List<BadmintonMatch> initalSelection,
  }) : super(
          CustomPrintSelectionState(
            selectedMatches: ListInput.pure(initalSelection),
            matches: _createSelectableMatches(progressState),
          ),
        ) {
    _emitState(state);
  }

  void matchToggled(BadmintonMatch match) {
    ListInput<BadmintonMatch> newSelection;

    if (state.selectedMatches.value.contains(match)) {
      newSelection = state.selectedMatches.copyWithRemovedValue(match);
    } else {
      newSelection = state.selectedMatches.copyWithAddedValue(match);
    }

    _emitState(state.copyWith(selectedMatches: newSelection));
  }

  void printCategoryToggled(PrintCategory category) {
    Set<BadmintonMatch> categoryMembers = state.matches[category]!.toSet();
    Set<BadmintonMatch> currentSelection = state.selectedMatches.value.toSet();

    Set<BadmintonMatch> selectedCategoryMembers =
        currentSelection.intersection(categoryMembers);

    if (selectedCategoryMembers.length == categoryMembers.length) {
      currentSelection.removeAll(selectedCategoryMembers);
    } else {
      currentSelection.addAll(categoryMembers);
    }

    ListInput<BadmintonMatch> newSelection =
        state.selectedMatches.copyWith(currentSelection.toList());

    _emitState(state.copyWith(
      selectedMatches: newSelection,
    ));
  }

  bool? _getCategorySelectionTristate(
    Set<BadmintonMatch> currentSelection,
    PrintCategory category,
  ) {
    Set<BadmintonMatch> categoryMembers = state.matches[category]!.toSet();

    Set<BadmintonMatch> selectedCategoryMembers =
        currentSelection.intersection(categoryMembers);

    if (selectedCategoryMembers.length == categoryMembers.length) {
      return true;
    }

    if (selectedCategoryMembers.isEmpty) {
      return false;
    }

    return null;
  }

  void _emitState(CustomPrintSelectionState state) {
    Set<BadmintonMatch> currentSelection = state.selectedMatches.value.toSet();

    Map<PrintCategory, bool?> printCategorySelectionTristates = {
      for (PrintCategory category in PrintCategory.values)
        category: _getCategorySelectionTristate(currentSelection, category),
    };

    emit(state.copyWith(
      printCategorySelectionTristates: printCategorySelectionTristates,
    ));
  }

  static Map<PrintCategory, List<BadmintonMatch>> _createSelectableMatches(
    TournamentProgressState progressState,
  ) {
    List<BadmintonMatch> allMatches = progressState.runningTournaments.values
        .expand((t) => t.matches)
        .where((m) => !m.isBye)
        .toList();

    Map<PrintCategory, List<BadmintonMatch>> matches = {
      PrintCategory.readyForCallOut: allMatches
          .where((m) => m.isPlayable && m.court != null && m.startTime == null)
          .toList(),
      PrintCategory.noCourt:
          allMatches.where((m) => m.isPlayable && m.court == null).toList(),
      PrintCategory.waitingForQualification:
          allMatches.where((m) => !m.isPlayable).toList(),
      PrintCategory.alreadyRunning:
          allMatches.where((m) => m.inProgress).toList(),
    };

    return matches;
  }
}
