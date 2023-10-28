part of 'game_sheet_printing_cubit.dart';

class GameSheetPrintingState {
  GameSheetPrintingState({
    required this.tournamentProgressState,
    this.formStatus = FormzSubmissionStatus.initial,
    this.printSelection = PrintSelection.readyForCallOut,
    this.matchesToPrint = const [],
    this.gameSheetPdf = const SelectionInput.dirty(),
    this.printedFile = const SelectionInput.dirty(),
    this.openedFile = const SelectionInput.dirty(),
    this.openedDirectory = const SelectionInput.dirty(),
  });

  final TournamentProgressState tournamentProgressState;

  final FormzSubmissionStatus formStatus;

  final PrintSelection printSelection;

  final List<BadmintonMatch> matchesToPrint;

  final SelectionInput<pw.Document> gameSheetPdf;

  final SelectionInput<Uint8List> printedFile;
  final SelectionInput<File> openedFile;
  final SelectionInput<Directory> openedDirectory;

  int? get numPages => gameSheetPdf.value?.document.pdfPageList.pages.length;
  int get numSheets => matchesToPrint.length;

  GameSheetPrintingState copyWith({
    TournamentProgressState? tournamentProgressState,
    FormzSubmissionStatus? formStatus,
    PrintSelection? printSelection,
    List<BadmintonMatch>? matchesToPrint,
    SelectionInput<pw.Document>? gameSheetPdf,
    SelectionInput<Uint8List>? printedFile,
    SelectionInput<File>? openedFile,
    SelectionInput<Directory>? openedDirectory,
  }) {
    return GameSheetPrintingState(
      tournamentProgressState:
          tournamentProgressState ?? this.tournamentProgressState,
      formStatus: formStatus ?? this.formStatus,
      printSelection: printSelection ?? this.printSelection,
      matchesToPrint: matchesToPrint ?? this.matchesToPrint,
      gameSheetPdf: gameSheetPdf ?? this.gameSheetPdf,
      printedFile: printedFile ?? this.printedFile,
      openedFile: openedFile ?? this.openedFile,
      openedDirectory: openedDirectory ?? this.openedDirectory,
    );
  }
}

enum PrintSelection {
  readyForCallOut,
  playersQualified,
  playersPartiallyQualified,
  allUnprinted,
}
