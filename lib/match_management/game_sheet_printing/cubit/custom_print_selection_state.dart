part of 'custom_print_selection_cubit.dart';

class CustomPrintSelectionState with FormzMixin {
  CustomPrintSelectionState({
    this.matches = const {},
    required this.selectedMatches,
    this.printCategorySelectionTristates = const {},
    required this.progressState,
    this.filter = const {},
  });

  final Map<PrintCategory, List<BadmintonMatch>> matches;

  final ListInput<BadmintonMatch> selectedMatches;

  final Map<PrintCategory, bool?> printCategorySelectionTristates;

  final TournamentProgressState progressState;
  final Map<Type, Predicate> filter;

  CustomPrintSelectionState copyWith({
    Map<PrintCategory, List<BadmintonMatch>>? matches,
    ListInput<BadmintonMatch>? selectedMatches,
    Map<PrintCategory, bool?>? printCategorySelectionTristates,
    TournamentProgressState? progressState,
    Map<Type, Predicate>? filter,
  }) {
    return CustomPrintSelectionState(
      matches: matches ?? this.matches,
      selectedMatches: selectedMatches ?? this.selectedMatches,
      printCategorySelectionTristates: printCategorySelectionTristates ??
          this.printCategorySelectionTristates,
      progressState: progressState ?? this.progressState,
      filter: filter ?? this.filter,
    );
  }

  @override
  List<FormzInput> get inputs => [selectedMatches];
}

enum PrintCategory {
  readyForCallOut,
  noCourt,
  waitingForQualification,
  alreadyRunning,
}
