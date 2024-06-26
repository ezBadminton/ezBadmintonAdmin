import 'dart:io';
import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:ez_badminton_admin_app/assets/pdf_fonts.dart';
import 'package:ez_badminton_admin_app/printing/pdf_printing_cubit.dart';
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
    extends CollectionQuerierCubit<GameSheetPrintingState>
    with PdfPrintingCubit {
  GameSheetPrintingCubit({
    required TournamentProgressState tournamentProgressState,
    required this.l10n,
    required CollectionRepository<MatchData> matchDataRepository,
    required CollectionRepository<Tournament> tournamentRepository,
  }) : super(
          collectionRepositories: [
            matchDataRepository,
            tournamentRepository,
          ],
          GameSheetPrintingState(
            tournamentProgressState: tournamentProgressState,
          ),
        ) {
    _emitStateWithPdf(state);
    subscribeToCollectionUpdates(
      tournamentRepository,
      (_) => _emitStateWithPdf(state),
    );
  }

  final AppLocalizations l10n;

  @override
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

  @override
  void saveLocationOpened() async {
    Directory saveLocation = await getSaveLocationDir();

    emit(state.copyWith(
      openedDirectory: SelectionInput.dirty(value: saveLocation),
    ));
  }

  void printSelectionChanged(PrintSelection selection) {
    _emitStateWithPdf(
      state.copyWith(printSelection: selection),
    );
  }

  void tournamentProgressChanged(TournamentProgressState progressState) {
    GameSheetPrintingState newState = state.copyWith(
      tournamentProgressState: progressState,
      customSelection: _updateCustomPrintSelection(progressState),
    );

    _emitStateWithPdf(newState);
  }

  /// Changes the [customSelection] to be printed.
  ///
  /// Used for [PrintSelection.custom].
  void customSelectionChanged(List<BadmintonMatch> customSelection) {
    _emitStateWithPdf(
      state.copyWith(customSelection: customSelection),
    );
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
    List<BadmintonMatch> matches = switch (state.printSelection) {
      PrintSelection.custom => state.customSelection,
      _ => state.tournamentProgressState.runningTournaments.values
          .expand((t) => t.matches)
          .toList(),
    };

    Tournament tournament = querier.getCollection<Tournament>().first;

    bool excludePrinted = tournament.dontReprintGameSheets;
    bool qrCodeEnabled = tournament.printQrCodes;

    List<BadmintonMatch> matchPrintSelection = switch (state.printSelection) {
      PrintSelection.custom => matches,
      _ => _getMatchPrintSelection(
          state.printSelection,
          matches,
          excludePrinted,
        ),
    };

    pw.Document? pdf = matchPrintSelection.isEmpty
        ? null
        : await _createPdf(matchPrintSelection, qrCodeEnabled);

    GameSheetPrintingState stateWithPdf = state.copyWith(
      matchesToPrint: matchPrintSelection,
      pdfDocument: SelectionInput.dirty(value: pdf),
    );

    emit(stateWithPdf);
  }

  Future<pw.Document> _createPdf(
    List<BadmintonMatch> matchesToPrint,
    bool qrCodeEnabled,
  ) async {
    pw.Document pdf = pw.Document();

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
            fontNormal: PdfFonts().interNormal,
            fontBold: PdfFonts().interBold,
            fontSize: 10,
          ),
          child: GameSheetPage(
            matches: matchesToPrint,
            l10n: l10n,
            qrCodeEnabled: qrCodeEnabled,
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
    bool excludePrinted,
  ) {
    Iterable<BadmintonMatch> unprintedMatches = matches.where(
      (m) =>
          !m.isBye &&
          (!excludePrinted || !m.matchData!.gameSheetPrinted) &&
          !m.inProgress &&
          m.endTime == null,
    );

    Iterable<BadmintonMatch> selectedMatches = switch (printSelection) {
      PrintSelection.allUpcoming => unprintedMatches,
      PrintSelection.playersPartiallyQualified => unprintedMatches.where(
          (m) => m.a.readyToPlay || m.b.readyToPlay,
        ),
      PrintSelection.playersQualified => unprintedMatches.where(
          (m) => m.isPlayable,
        ),
      PrintSelection.readyForCallOut => unprintedMatches.where(
          (m) => m.isPlayable && m.court != null,
        ),
      PrintSelection.custom => [],
    };

    return selectedMatches.toList();
  }

  Future<(File?, Uint8List?)> _savePdf() async {
    if (state.pdfDocument.value == null) {
      return (null, null);
    }

    Directory gameSheetDir = await getSaveLocationDir();

    final String pdfFileName = getPdfFileName(
      (fileIndex) => 'game_sheets_${fileIndex.toString().padLeft(3, '0')}.pdf',
      gameSheetDir,
    );

    final File file = File(p.join(gameSheetDir.path, pdfFileName));

    final Uint8List pdfBytes = await state.pdfDocument.value!.save();

    await file.writeAsBytes(pdfBytes);

    return (file, pdfBytes);
  }

  List<BadmintonMatch> _updateCustomPrintSelection(
    TournamentProgressState progressState,
  ) {
    List<BadmintonMatch> matches = progressState.runningTournaments.values
        .expand((t) => t.matches)
        .where((m) => !m.isBye)
        .toList();

    List<BadmintonMatch> updatedSelection = state.customSelection
        .map(
          (match) =>
              matches.firstWhereOrNull((m) => match.matchData == m.matchData),
        )
        .whereType<BadmintonMatch>()
        .toList();

    return updatedSelection;
  }

  @override
  Future<Directory> getSaveLocationDir() async {
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

  @override
  void onCollectionUpdate(List<List<Model>> collections,
      List<CollectionUpdateEvent<Model>> updateEvents) {}
}
