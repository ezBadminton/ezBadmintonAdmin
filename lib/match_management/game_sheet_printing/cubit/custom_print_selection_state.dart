part of 'custom_print_selection_cubit.dart';

class CustomPrintSelectionState with FormzMixin {
  CustomPrintSelectionState({
    this.matches = const {},
    required this.selectedMatches,
    this.printCategorySelectionTristates = const {},
  });

  final Map<PrintCategory, List<BadmintonMatch>> matches;

  final ListInput<BadmintonMatch> selectedMatches;

  final Map<PrintCategory, bool?> printCategorySelectionTristates;

  CustomPrintSelectionState copyWith({
    Map<PrintCategory, List<BadmintonMatch>>? matches,
    ListInput<BadmintonMatch>? selectedMatches,
    Map<PrintCategory, bool?>? printCategorySelectionTristates,
  }) {
    return CustomPrintSelectionState(
      matches: matches ?? this.matches,
      selectedMatches: selectedMatches ?? this.selectedMatches,
      printCategorySelectionTristates: printCategorySelectionTristates ??
          this.printCategorySelectionTristates,
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
