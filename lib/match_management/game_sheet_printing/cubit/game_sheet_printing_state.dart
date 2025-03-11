part of 'game_sheet_printing_cubit.dart';

class GameSheetPrintingState extends CollectionQuerierState
    implements PdfPrintingState {
  GameSheetPrintingState({
    this.loadingStatus = LoadingStatus.loading,
    this.formStatus = FormzSubmissionStatus.initial,
    this.printSelection = PrintSelection.readyForCallOut,
    this.matches = const [],
    this.matchesToPrint = const [],
    this.customSelection = const [],
    this.pdfDocument = const SelectionInput.dirty(),
    this.openedFile = const SelectionInput.dirty(),
    this.openedDirectory = const SelectionInput.dirty(),
    this.collections = const [],
  });

  @override
  final LoadingStatus loadingStatus;

  @override
  final FormzSubmissionStatus formStatus;

  final PrintSelection printSelection;

  final List<MatchContext> matches;
  final List<MatchContext> matchesToPrint;
  final List<MatchContext> customSelection;

  @override
  final SelectionInput<pw.Document> pdfDocument;

  @override
  final SelectionInput<File> openedFile;

  @override
  final SelectionInput<Directory> openedDirectory;

  @override
  final List<List<Model>> collections;

  int? get numPages => pdfDocument.value?.document.pdfPageList.pages.length;
  int get numSheets => matchesToPrint.length;

  GameSheetPrintingState copyWith({
    LoadingStatus? loadingStatus,
    FormzSubmissionStatus? formStatus,
    PrintSelection? printSelection,
    List<MatchContext>? matches,
    List<MatchContext>? matchesToPrint,
    List<MatchContext>? customSelection,
    SelectionInput<pw.Document>? pdfDocument,
    SelectionInput<File>? openedFile,
    SelectionInput<Directory>? openedDirectory,
    List<List<Model>>? collections,
  }) {
    return GameSheetPrintingState(
      loadingStatus: loadingStatus ?? this.loadingStatus,
      formStatus: formStatus ?? this.formStatus,
      printSelection: printSelection ?? this.printSelection,
      matches: matches ?? this.matches,
      matchesToPrint: matchesToPrint ?? this.matchesToPrint,
      customSelection: customSelection ?? this.customSelection,
      pdfDocument: pdfDocument ?? this.pdfDocument,
      openedFile: openedFile ?? this.openedFile,
      openedDirectory: openedDirectory ?? this.openedDirectory,
      collections: collections ?? this.collections,
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
