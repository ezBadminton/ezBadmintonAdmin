part of 'custom_print_selection_cubit.dart';

class CustomPrintSelectionState extends CollectionQuerierState with FormzMixin {
  CustomPrintSelectionState({
    this.loadingStatus = LoadingStatus.loading,
    this.matches = const {},
    required this.selectedMatches,
    this.printCategorySelectionTristates = const {},
    this.filter = const {},
    this.collections = const [],
  });

  @override
  final LoadingStatus loadingStatus;

  final Map<PrintCategory, List<ScheduledMatchContext>> matches;

  final ListInput<ScheduledMatchContext> selectedMatches;

  final Map<PrintCategory, bool?> printCategorySelectionTristates;

  final Map<Type, Predicate> filter;

  @override
  final List<List<Model>> collections;

  CustomPrintSelectionState copyWith({
    LoadingStatus? loadingStatus,
    Map<PrintCategory, List<ScheduledMatchContext>>? matches,
    ListInput<ScheduledMatchContext>? selectedMatches,
    Map<PrintCategory, bool?>? printCategorySelectionTristates,
    Map<Type, Predicate>? filter,
    List<List<Model>>? collections,
  }) {
    return CustomPrintSelectionState(
      loadingStatus: loadingStatus ?? this.loadingStatus,
      matches: matches ?? this.matches,
      selectedMatches: selectedMatches ?? this.selectedMatches,
      printCategorySelectionTristates: printCategorySelectionTristates ??
          this.printCategorySelectionTristates,
      filter: filter ?? this.filter,
      collections: collections ?? this.collections,
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
