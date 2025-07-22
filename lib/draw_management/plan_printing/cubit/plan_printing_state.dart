part of 'plan_printing_cubit.dart';

class PlanPrintingState implements PdfPrintingState {
  const PlanPrintingState({
    this.tournaments = const [],
    this.printBigPage = false,
    this.printWithScores = false,
    this.formStatus = FormzSubmissionStatus.initial,
    this.pdfDocument = const SelectionInput.pure(),
    this.openedFile = const SelectionInput.pure(),
    this.openedDirectory = const SelectionInput.pure(),
  });

  final List<models.TournamentPlan> tournaments;

  final bool printBigPage;

  final bool printWithScores;

  @override
  final FormzSubmissionStatus formStatus;

  @override
  final SelectionInput<pw.Document> pdfDocument;

  @override
  final SelectionInput<File> openedFile;

  @override
  final SelectionInput<Directory> openedDirectory;

  PlanPrintingState copyWith({
    List<models.TournamentPlan>? tournaments,
    bool? printBigPage,
    bool? printWithScores,
    FormzSubmissionStatus? formStatus,
    SelectionInput<pw.Document>? pdfDocument,
    SelectionInput<File>? openedFile,
    SelectionInput<Directory>? openedDirectory,
  }) {
    return PlanPrintingState(
      tournaments: tournaments ?? this.tournaments,
      printBigPage: printBigPage ?? this.printBigPage,
      printWithScores: printWithScores ?? this.printWithScores,
      formStatus: formStatus ?? this.formStatus,
      pdfDocument: pdfDocument ?? this.pdfDocument,
      openedFile: openedFile ?? this.openedFile,
      openedDirectory: openedDirectory ?? this.openedDirectory,
    );
  }
}
