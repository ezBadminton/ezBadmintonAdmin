part of 'plan_printing_cubit.dart';

class PlanPrintingState implements PdfPrintingState {
  const PlanPrintingState({
    this.tournaments = const [],
    this.formStatus = FormzSubmissionStatus.initial,
    this.pdfDocument = const SelectionInput.pure(),
    this.openedFile = const SelectionInput.pure(),
    this.openedDirectory = const SelectionInput.pure(),
  });

  final List<BadmintonTournamentMode> tournaments;

  @override
  final FormzSubmissionStatus formStatus;

  @override
  final SelectionInput<pw.Document> pdfDocument;

  @override
  final SelectionInput<File> openedFile;

  @override
  final SelectionInput<Directory> openedDirectory;

  PlanPrintingState copyWith({
    List<BadmintonTournamentMode>? tournaments,
    SelectionInput<pw.Document>? pdfDocument,
    SelectionInput<File>? openedFile,
    SelectionInput<Directory>? openedDirectory,
  }) {
    return PlanPrintingState(
      tournaments: tournaments ?? this.tournaments,
      pdfDocument: pdfDocument ?? this.pdfDocument,
      openedFile: openedFile ?? this.openedFile,
      openedDirectory: openedDirectory ?? this.openedDirectory,
    );
  }
}
