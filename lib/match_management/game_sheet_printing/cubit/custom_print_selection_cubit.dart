import 'package:collection/collection.dart';
import 'package:ez_badminton_admin_app/collection_queries/collection_querier.dart';
import 'package:ez_badminton_admin_app/widgets/loading_screen/loading_screen.dart';
import 'package:ez_badminton_admin_app/widgets/tournament_context/tournament_context.dart';
import 'package:formz/formz.dart';
import 'package:model_repository/model_repository.dart';
import 'package:ez_badminton_admin_app/input_models/list_input.dart';
import 'package:ez_badminton_admin_app/predicate_filter/predicate/filter_predicate.dart';
import 'package:flutter/foundation.dart';
part 'custom_print_selection_state.dart';

class CustomPrintSelectionCubit
    extends CollectionQuerierCubit<CustomPrintSelectionState> {
  CustomPrintSelectionCubit({
    required ModelStore<ScheduledMatch> scheduledMatchStore,
    required ModelStore<ScheduledRound> scheduledRoundStore,
    required List<MatchContext> initalSelection,
  }) : super(
          modelStores: [
            scheduledMatchStore,
            scheduledRoundStore,
          ],
          CustomPrintSelectionState(
            selectedMatches: ListInput.pure(initalSelection),
          ),
        );

  @override
  void onCollectionUpdate(
    List<List<Model>> collections,
    CollectionUpdateEvent<Model>? updateEvent,
  ) {
    var updatedState = state.copyWith(
      loadingStatus: LoadingStatus.done,
      collections: collections,
    );

    _emitState(updatedState);
  }

  void matchToggled(MatchContext match) {
    ListInput<MatchContext> newSelection;

    if (state.selectedMatches.value.contains(match)) {
      newSelection = state.selectedMatches.copyWithRemovedValue(match);
    } else {
      newSelection = state.selectedMatches.copyWithAddedValue(match);
    }

    _emitState(state.copyWith(selectedMatches: newSelection));
  }

  void printCategoryToggled(PrintCategory category) {
    Set<MatchContext> categoryMembers = state.matches[category]!.toSet();

    if (categoryMembers.isEmpty) {
      return;
    }

    Set<MatchContext> currentSelection = state.selectedMatches.value.toSet();

    Set<MatchContext> selectedCategoryMembers =
        currentSelection.intersection(categoryMembers);

    if (selectedCategoryMembers.length == categoryMembers.length) {
      currentSelection.removeAll(selectedCategoryMembers);
    } else {
      currentSelection.addAll(categoryMembers);
    }

    ListInput<MatchContext> newSelection =
        state.selectedMatches.copyWith(currentSelection.toList());

    _emitState(state.copyWith(
      selectedMatches: newSelection,
    ));
  }

  void filterChanged(Map<Type, Predicate> filter) {
    CustomPrintSelectionState newState = state.copyWith(
      filter: filter,
    );

    _emitState(newState);
  }

  static bool? _getCategorySelectionTristate(
    Map<PrintCategory, List<MatchContext>> matches,
    Set<MatchContext> currentSelection,
    PrintCategory category,
  ) {
    Set<MatchContext> categoryMembers = matches[category]!.toSet();

    Set<MatchContext> selectedCategoryMembers =
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
    Map<PrintCategory, List<MatchContext>> newMatches =
        _createSelectableMatches(state, state.filter);

    List<MatchContext> selectableMatches =
        newMatches.values.expand((e) => e).toList();
    Set<MatchContext> filteredSelection = state.selectedMatches.value
        .map(
          (match) => selectableMatches.firstWhereOrNull((m) => match == m),
        )
        .whereType<MatchContext>()
        .toSet();

    Set<MatchContext> currentSelection =
        this.state.selectedMatches.value.toSet();

    ListInput<MatchContext> newSelection;
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

  static Map<PrintCategory, List<MatchContext>> _createSelectableMatches(
    CustomPrintSelectionState state,
    Map<Type, Predicate> filter,
  ) {
    Predicate? competitionFilter = filter[Competition];
    Predicate? playerFilter = filter[Player];

    List<MatchContext> allMatches = state
        .getCollection<ScheduledRound>()
        .where(
          // Filter round by competition filter
          (round) => competitionFilter?.call(round.competition) ?? true,
        )
        .expand(
          (round) => round.matches.map(
            (m) => MatchContext(
              tournamentPlan: round.competition.tournamentPlan!,
              scheduledMatch: m,
            ),
          ),
        )
        .where(
          // Filter match by player filter (one match in the players is enough)
          (m) => playerFilter == null
              ? true
              : m.match.players.where((p) => playerFilter.call(p)).isNotEmpty,
        )
        .toList();

    Map<PrintCategory, List<MatchContext>> matches = {
      PrintCategory.readyForCallOut: [],
      PrintCategory.noCourt: [],
      PrintCategory.waitingForQualification: [],
      PrintCategory.alreadyRunning: [],
    };

    for (var mContext in allMatches) {
      switch (mContext.scheduledMatch.status) {
        case ScheduleStatus.done:
        case ScheduleStatus.scoreUnknown:
          break;
        case ScheduleStatus.inProgress:
          matches[PrintCategory.alreadyRunning]!.add(mContext);
        case ScheduleStatus.ready:
          matches[PrintCategory.readyForCallOut]!.add(mContext);
        case ScheduleStatus.courtWait:
        case ScheduleStatus.playerRest:
        case ScheduleStatus.playerWait:
          matches[PrintCategory.noCourt]!.add(mContext);
        case ScheduleStatus.wait:
          matches[PrintCategory.waitingForQualification]!.add(mContext);
      }
    }

    return matches;
  }
}
