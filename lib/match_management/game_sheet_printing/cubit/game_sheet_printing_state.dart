part of 'game_sheet_printing_cubit.dart';

class GameSheetPrintingState {
  GameSheetPrintingState({
    required this.tournamentProgressState,
    this.formStatus = FormzSubmissionStatus.initial,
    this.printSelection = PrintSelection.readyForCallOut,
    this.matchesToPrint = const [],
    this.customSelection = const [],
    this.gameSheetPdf = const SelectionInput.dirty(),
    this.openedFile = const SelectionInput.dirty(),
    this.openedDirectory = const SelectionInput.dirty(),
  });

  final TournamentProgressState tournamentProgressState;

  final FormzSubmissionStatus formStatus;

  final PrintSelection printSelection;

  final List<BadmintonMatch> matchesToPrint;
  final List<BadmintonMatch> customSelection;

  final SelectionInput<pw.Document> gameSheetPdf;

  final SelectionInput<File> openedFile;
  final SelectionInput<Directory> openedDirectory;

  int? get numPages => gameSheetPdf.value?.document.pdfPageList.pages.length;
  int get numSheets => matchesToPrint.length;

  GameSheetPrintingState copyWith({
    TournamentProgressState? tournamentProgressState,
    FormzSubmissionStatus? formStatus,
    PrintSelection? printSelection,
    List<BadmintonMatch>? matchesToPrint,
    List<BadmintonMatch>? customSelection,
    SelectionInput<pw.Document>? gameSheetPdf,
    SelectionInput<File>? openedFile,
    SelectionInput<Directory>? openedDirectory,
  }) {
    return GameSheetPrintingState(
      tournamentProgressState:
          tournamentProgressState ?? this.tournamentProgressState,
      formStatus: formStatus ?? this.formStatus,
      printSelection: printSelection ?? this.printSelection,
      matchesToPrint: matchesToPrint ?? this.matchesToPrint,
      customSelection: customSelection ?? this.customSelection,
      gameSheetPdf: gameSheetPdf ?? this.gameSheetPdf,
      openedFile: openedFile ?? this.openedFile,
      openedDirectory: openedDirectory ?? this.openedDirectory,
    );
  }
}

enum PrintSelection {
  readyForCallOut,
  playersQualified,
  playersPartiallyQualified,
  allUpcoming,
  custom,
}
