part of 'certificate_printing_cubit.dart';

class CertificatePrintingState implements PdfPrintingState {
  const CertificatePrintingState({
    this.tournaments = const [],
    this.pdfDocument = const SelectionInput.pure(),
    this.openedFile = const SelectionInput.pure(),
    this.openedDirectory = const SelectionInput.pure(),
    this.formStatus = FormzSubmissionStatus.initial,
  });

  final List<models.TournamentPlan> tournaments;

  @override
  final SelectionInput<pw.Document> pdfDocument;

  @override
  final SelectionInput<File> openedFile;

  @override
  final SelectionInput<Directory> openedDirectory;

  @override
  final FormzSubmissionStatus formStatus;

  CertificatePrintingState copyWith({
    List<models.TournamentPlan>? tournaments,
    SelectionInput<pw.Document>? pdfDocument,
    SelectionInput<File>? openedFile,
    SelectionInput<Directory>? openedDirectory,
    FormzSubmissionStatus? formStatus,
  }) {
    return CertificatePrintingState(
      tournaments: tournaments ?? this.tournaments,
      pdfDocument: pdfDocument ?? this.pdfDocument,
      openedFile: openedFile ?? this.openedFile,
      openedDirectory: openedDirectory ?? this.openedDirectory,
      formStatus: formStatus ?? this.formStatus,
    );
  }
}
