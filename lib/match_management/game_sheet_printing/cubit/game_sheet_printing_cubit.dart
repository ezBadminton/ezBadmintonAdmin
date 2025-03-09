import 'dart:io';
import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:ez_badminton_admin_app/assets/pdf_fonts.dart';
import 'package:ez_badminton_admin_app/printing/pdf_printing_cubit.dart';
import 'package:ez_badminton_admin_app/widgets/loading_screen/loading_screen.dart';
import 'package:ez_badminton_admin_app/widgets/tournament_context/tournament_context.dart';
import 'package:path/path.dart' as p;
import 'package:model_repository/model_repository.dart';
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
    required this.l10n,
    required ModelStore<TournamentEvent> tournamentStore,
    required ModelStore<ScheduledMatch> scheduledMatchStore,
    required ModelStore<ScheduledRound> scheduledRoundStore,
  }) : super(
          modelStores: [
            tournamentStore,
            scheduledMatchStore,
            scheduledRoundStore,
          ],
          GameSheetPrintingState(),
        );

  final AppLocalizations l10n;

  @override
  void onCollectionUpdate(
    List<List<Model>> collections,
    List<CollectionUpdateEvent<Model>> updateEvents,
  ) {
    var updatedState = state.copyWith(
      loadingStatus: LoadingStatus.done,
      collections: collections,
    );

    var matches = updatedState.getCollection<ScheduledRound>().expand((round) {
      var tPlan = round.competition.tournamentPlan!;
      return round.matches.map((m) => ScheduledMatchContext(tPlan, m));
    }).toList();

    updatedState = updatedState.copyWith(matches: matches);
    updatedState = _updateCustomPrintSelection(updatedState);

    _emitStateWithPdf(updatedState);
  }

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

  /// Changes the [customSelection] to be printed.
  ///
  /// Used for [PrintSelection.custom].
  void customSelectionChanged(List<ScheduledMatchContext> customSelection) {
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
    // TODO
    /*
    List<MatchData> matchDataWithPrintedFlag = state.matchesToPrint
        .map((m) => m.matchData.copyWith(gameSheetPrinted: true))
        .toList();

    List<MatchData?> updatedMatchData =
        await querier.updateModels(matchDataWithPrintedFlag);
    if (updatedMatchData.contains(null)) {
      return FormzSubmissionStatus.failure;
    }
    */

    return FormzSubmissionStatus.success;
  }

  void _emitStateWithPdf(
    GameSheetPrintingState state,
  ) async {
    List<ScheduledMatchContext> matches = switch (state.printSelection) {
      PrintSelection.custom => state.customSelection,
      _ => state.matches,
    };

    TournamentEvent tournament = querier.getCollection<TournamentEvent>().first;

    bool excludePrinted = tournament.dontReprintGameSheets;
    bool qrCodeEnabled = tournament.printQrCodes;

    List<ScheduledMatchContext> matchPrintSelection =
        switch (state.printSelection) {
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
    List<MatchContext> matchesToPrint,
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

  List<ScheduledMatchContext> _getMatchPrintSelection(
    PrintSelection printSelection,
    List<ScheduledMatchContext> matches,
    bool excludePrinted,
  ) {
    Iterable<ScheduledMatchContext> unprintedMatches = matches.where(
      (m) =>
          !m.match.isBye &&
          (!excludePrinted || !m.match.gameSheetPrinted) &&
          m.scheduledMatch.status != ScheduleStatus.inProgress &&
          m.match.endTime == null,
    );

    Iterable<ScheduledMatchContext> selectedMatches = switch (printSelection) {
      PrintSelection.allUpcoming => unprintedMatches,
      PrintSelection.playersPartiallyQualified => unprintedMatches.where(
          (m) => m.match.slot1.team != null || m.match.slot2.team != null,
        ),
      PrintSelection.playersQualified => unprintedMatches.where(
          (m) => [
            ScheduleStatus.courtWait,
            ScheduleStatus.playerRest,
            ScheduleStatus.playerWait,
          ].contains(m.scheduledMatch.status),
        ),
      PrintSelection.readyForCallOut => unprintedMatches.where(
          (m) => m.scheduledMatch.status == ScheduleStatus.ready,
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

  GameSheetPrintingState _updateCustomPrintSelection(
    GameSheetPrintingState state,
  ) {
    List<ScheduledMatchContext> updatedSelection = state.customSelection
        .map(
          (match) => state.matches.firstWhereOrNull((m) => match == m),
        )
        .whereType<ScheduledMatchContext>()
        .toList();

    return state.copyWith(customSelection: updatedSelection);
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
}
