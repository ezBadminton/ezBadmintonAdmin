import 'package:collection/collection.dart';
import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/badminton_tournament_ops/badminton_match.dart';
import 'package:ez_badminton_admin_app/badminton_tournament_ops/cubit/tournament_progress_cubit.dart';
import 'package:ez_badminton_admin_app/input_models/list_input.dart';
import 'package:ez_badminton_admin_app/predicate_filter/predicate/filter_predicate.dart';
import 'package:flutter/foundation.dart';
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
            matches: _createSelectableMatches(progressState, const {}),
            progressState: progressState,
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

    if (categoryMembers.isEmpty) {
      return;
    }

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

  void tournamentProgressChanged(TournamentProgressState progressState) {
    CustomPrintSelectionState newState = state.copyWith(
      progressState: progressState,
    );

    _emitState(newState);
  }

  void filterChanged(Map<Type, Predicate> filter) {
    CustomPrintSelectionState newState = state.copyWith(
      filter: filter,
    );

    _emitState(newState);
  }

  static bool? _getCategorySelectionTristate(
    Map<PrintCategory, List<BadmintonMatch>> matches,
    Set<BadmintonMatch> currentSelection,
    PrintCategory category,
  ) {
    Set<BadmintonMatch> categoryMembers = matches[category]!.toSet();

    Set<BadmintonMatch> selectedCategoryMembers =
        currentSelection.intersection(categoryMembers);

    if (selectedCategoryMembers.isEmpty) {
      return false;
    }

    if (selectedCategoryMembers.length == categoryMembers.length) {
      return true;
    }

    return null;
  }

  void _emitState(CustomPrintSelectionState state) {
    Map<PrintCategory, List<BadmintonMatch>> newMatches =
        _createSelectableMatches(state.progressState, state.filter);

    List<BadmintonMatch> selectableMatches =
        newMatches.values.expand((e) => e).toList();
    Set<BadmintonMatch> filteredSelection = state.selectedMatches.value
        .map(
          (match) => selectableMatches
              .firstWhereOrNull((m) => match.matchData == m.matchData),
        )
        .whereType<BadmintonMatch>()
        .toSet();

    Set<BadmintonMatch> currentSelection =
        this.state.selectedMatches.value.toSet();

    ListInput<BadmintonMatch> newSelection;
    if (setEquals(currentSelection, filteredSelection)) {
      newSelection = this.state.selectedMatches;
    } else {
      newSelection = state.selectedMatches.copyWith(filteredSelection.toList());
    }

    Map<PrintCategory, bool?> printCategorySelectionTristates = {
      for (PrintCategory category in PrintCategory.values)
        category: _getCategorySelectionTristate(
          newMatches,
          filteredSelection,
          category,
        ),
    };

    emit(state.copyWith(
      matches: newMatches,
      selectedMatches: newSelection,
      printCategorySelectionTristates: printCategorySelectionTristates,
    ));
  }

  static Map<PrintCategory, List<BadmintonMatch>> _createSelectableMatches(
    TournamentProgressState progressState,
    Map<Type, Predicate> filter,
  ) {
    Predicate? competitionFilter = filter[Competition];
    Predicate? playerFilter = filter[Player];

    List<BadmintonMatch> allMatches = progressState.runningTournaments.values
        .expand((t) => t.matches)
        .where((m) => !m.isBye && !m.isWalkover)
        .where(
          // Filter match by competition filter
          (m) => competitionFilter?.call(m.competition) ?? true,
        )
        .where(
          // Filter match by player filter (one match in the players is enough)
          (m) => playerFilter == null
              ? true
              : m
                  .getPlayersOfMatch()
                  .where((p) => playerFilter.call(p))
                  .isNotEmpty,
        )
        .toList();

    Map<PrintCategory, List<BadmintonMatch>> matches = {
      PrintCategory.readyForCallOut: allMatches
          .where((m) => m.isPlayable && m.court != null && m.startTime == null)
          .toList(),
      PrintCategory.noCourt: allMatches
          .where((m) => m.isPlayable && m.court == null && m.startTime == null)
          .toList(),
      PrintCategory.waitingForQualification:
          allMatches.where((m) => !m.isPlayable).toList(),
      PrintCategory.alreadyRunning:
          allMatches.where((m) => m.inProgress).toList(),
    };

    return matches;
  }
}
