import 'dart:io';
import 'dart:typed_data';

import 'package:ez_badminton_admin_app/constants.dart';
import 'package:path/path.dart' as p;
import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/badminton_tournament_ops/badminton_match.dart';
import 'package:ez_badminton_admin_app/badminton_tournament_ops/cubit/tournament_progress_cubit.dart';
import 'package:ez_badminton_admin_app/collection_queries/collection_querier.dart';
import 'package:ez_badminton_admin_app/input_models/models.dart';
import 'package:ez_badminton_admin_app/printing/pdf_widgets/game_sheet_page.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:formz/formz.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

part 'game_sheet_printing_state.dart';

class GameSheetPrintingCubit
    extends CollectionQuerierCubit<GameSheetPrintingState> {
  GameSheetPrintingCubit({
    required TournamentProgressState tournamentProgressState,
    required this.l10n,
    required CollectionRepository<MatchData> matchDataRepository,
  }) : super(
          collectionRepositories: [
            matchDataRepository,
          ],
          GameSheetPrintingState(
            tournamentProgressState: tournamentProgressState,
          ),
        ) {
    _emitStateWithPdf(state);
  }

  final AppLocalizations l10n;

  void sheetPrinted() async {
    if (state.formStatus == FormzSubmissionStatus.inProgress) {
      return;
    }

    emit(state.copyWith(formStatus: FormzSubmissionStatus.inProgress));

    final Uint8List? pdfBytes = (await _generateSheetsAndMarkAsPrinted()).$2;

    if (pdfBytes == null) {
      emit(state.copyWith(formStatus: FormzSubmissionStatus.failure));
      return;
    }

    emit(state.copyWith(
      formStatus: FormzSubmissionStatus.success,
      printedFile: SelectionInput.dirty(value: pdfBytes),
    ));
  }

  void pdfOpened() async {
    if (state.formStatus == FormzSubmissionStatus.inProgress) {
      return;
    }

    emit(state.copyWith(formStatus: FormzSubmissionStatus.inProgress));

    final File? pdfFile = (await _generateSheetsAndMarkAsPrinted()).$1;

    if (pdfFile == null) {
      emit(state.copyWith(formStatus: FormzSubmissionStatus.failure));
      return;
    }

    emit(state.copyWith(
      formStatus: FormzSubmissionStatus.success,
      openedFile: SelectionInput.dirty(value: pdfFile),
    ));
  }

  void saveLocationOpened() async {
    Directory saveLocation = await _getGameSheetDirectory();

    emit(state.copyWith(
      openedDirectory: SelectionInput.dirty(value: saveLocation),
    ));
  }

  void printSelectionChanged(PrintSelection selection) {
    _emitStateWithPdf(
      state.copyWith(printSelection: selection),
    );
  }

  void tournamentProgressStateChanged(TournamentProgressState progressState) {
    GameSheetPrintingState newState =
        state.copyWith(tournamentProgressState: progressState);

    _emitStateWithPdf(newState);
  }

  Future<(File?, Uint8List?)> _generateSheetsAndMarkAsPrinted() async {
    final (File?, Uint8List?) pdfFile = await _savePdf();

    if (pdfFile.$1 == null) {
      return (null, null);
    }

    FormzSubmissionStatus printMarkingStatus = await _markMatchesAsPrinted();
    if (printMarkingStatus != FormzSubmissionStatus.success) {
      return (null, null);
    }

    return pdfFile;
  }

  Future<FormzSubmissionStatus> _markMatchesAsPrinted() async {
    List<MatchData> matchDataWithPrintedFlag = state.matchesToPrint
        .map((m) => m.matchData!.copyWith(gameSheetPrinted: true))
        .toList();

    List<MatchData?> updatedMatchData =
        await querier.updateModels(matchDataWithPrintedFlag);
    if (updatedMatchData.contains(null)) {
      return FormzSubmissionStatus.failure;
    }

    return FormzSubmissionStatus.success;
  }

  void _emitStateWithPdf(
    GameSheetPrintingState state,
  ) async {
    List<BadmintonMatch> matches = state
        .tournamentProgressState.runningTournaments.values
        .expand((t) => t.matches)
        .toList();

    List<BadmintonMatch> matchPrintSelection =
        _getMatchPrintSelection(state.printSelection, matches);

    pw.Document pdf = await _createPdf(matchPrintSelection);

    GameSheetPrintingState stateWithPdf = state.copyWith(
      matchesToPrint: matchPrintSelection,
      gameSheetPdf: SelectionInput.dirty(value: pdf),
    );

    emit(stateWithPdf);
  }

  Future<pw.Document> _createPdf(List<BadmintonMatch> matchesToPrint) async {
    pw.Document pdf = pw.Document();
    final Uint8List fontData =
        File(p.join(fontDirPath, 'Inter', 'Inter.ttf')).readAsBytesSync();
    final pw.Font font = pw.Font.ttf(fontData.buffer.asByteData());

    double pageMargin = 0.65;
    PdfPageFormat pdfFormat = PdfPageFormat.a4.landscape.copyWith(
      marginTop: pageMargin * PdfPageFormat.cm,
      marginBottom: pageMargin * PdfPageFormat.cm,
      marginLeft: pageMargin * PdfPageFormat.cm,
      marginRight: pageMargin * PdfPageFormat.cm,
    );

    var pdfPage = pw.MultiPage(
      pageFormat: pdfFormat,
      orientation: pw.PageOrientation.landscape,
      build: (_) => [
        pw.DefaultTextStyle(
          style: pw.TextStyle(
            font: font,
            fontSize: 10,
          ),
          child: GameSheetPage(
            matches: matchesToPrint,
            l10n: l10n,
          ),
        ),
      ],
    );

    pdf.addPage(pdfPage);

    return pdf;
  }

  List<BadmintonMatch> _getMatchPrintSelection(
    PrintSelection printSelection,
    List<BadmintonMatch> matches,
  ) {
    Iterable<BadmintonMatch> unprintedMatches = matches.where(
      (m) =>
          !m.isBye &&
          !m.matchData!.gameSheetPrinted &&
          !m.inProgress &&
          !m.isCompleted,
    );

    Iterable<BadmintonMatch> selectedMatches = switch (printSelection) {
      PrintSelection.allUnprinted => unprintedMatches,
      PrintSelection.playersPartiallyQualified => unprintedMatches.where(
          (m) => m.a.readyToPlay || m.b.readyToPlay,
        ),
      PrintSelection.playersQualified => unprintedMatches.where(
          (m) => m.isPlayable,
        ),
      PrintSelection.readyForCallOut => unprintedMatches.where(
          (m) => m.isPlayable && m.court != null,
        ),
    };

    return selectedMatches.toList();
  }

  Future<(File?, Uint8List?)> _savePdf() async {
    if (state.gameSheetPdf.value == null) {
      return (null, null);
    }

    Directory gameSheetDir = await _getGameSheetDirectory();

    String fileName(int fileIndex) =>
        'game_sheets_${fileIndex.toString().padLeft(3, '0')}.pdf';

    int fileIndex = 0;
    List<String> existingSheetFileNames =
        gameSheetDir.listSync().map((e) => p.basename(e.path)).toList();

    while (existingSheetFileNames.contains(fileName(fileIndex))) {
      fileIndex += 1;
    }

    final String pdfFileName = fileName(fileIndex);

    final File file = File(p.join(gameSheetDir.path, pdfFileName));

    final Uint8List pdfBytes = await state.gameSheetPdf.value!.save();

    await file.writeAsBytes(pdfBytes);

    return (file, pdfBytes);
  }

  Future<Directory> _getGameSheetDirectory() async {
    final Directory documentDir = await getApplicationDocumentsDirectory();
    final String gameSheetPath = p.join(
      documentDir.path,
      'ez_badminton',
      'game_sheets',
    );
    final Directory gameSheetDir = Directory(gameSheetPath);
    if (!gameSheetDir.existsSync()) {
      await gameSheetDir.create(recursive: true);
    }

    return gameSheetDir;
  }
}
