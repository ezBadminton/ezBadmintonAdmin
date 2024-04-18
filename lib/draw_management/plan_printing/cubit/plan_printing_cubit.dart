import 'dart:io';
import 'dart:typed_data';

import 'package:bloc/bloc.dart';
import 'package:ez_badminton_admin_app/badminton_tournament_ops/badminton_tournament_modes.dart';
import 'package:ez_badminton_admin_app/input_models/models.dart';
import 'package:ez_badminton_admin_app/printing/pdf_printing_cubit.dart';
import 'package:ez_badminton_admin_app/printing/pdf_widgets/pdf_widgets.dart';
import 'package:formz/formz.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path/path.dart' as p;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

part 'plan_printing_state.dart';

class PlanPrintingCubit extends Cubit<PlanPrintingState> with PdfPrintingCubit {
  PlanPrintingCubit({
    required this.l10n,
  }) : super(const PlanPrintingState());

  final AppLocalizations l10n;

  void tournamentsChanged(List<BadmintonTournamentMode> tournaments) {
    emit(state.copyWith(tournaments: tournaments));
    _generatePdf();
  }

  @override
  void pdfOpened() {
    _saveAndOpenPdf();
  }

  void _generatePdf() {
    if (state.tournaments.isEmpty) {
      emit(state.copyWith(pdfDocument: const SelectionInput.dirty()));
      return;
    }

    final pdf = pw.Document();

    List<TournamentPlan> plans = state.tournaments.map((t) {
      switch (t) {
        case BadmintonSingleElimination singleElimination:
          return SingleEliminationPlan(
            tournament: singleElimination,
            l10n: l10n,
          );
        default:
          throw Exception("This mode has no plan implemented!");
      }
    }).toList();

    List<pw.Page> pages = plans.expand((p) => p.generatePdfPages()).toList();

    for (pw.Page page in pages) {
      pdf.addPage(page);
    }

    emit(state.copyWith(pdfDocument: SelectionInput.dirty(value: pdf)));
  }

  void _saveAndOpenPdf() async {
    if (state.pdfDocument.value == null) {
      return;
    }

    Directory matchPlanDir = await _getPlanPdfDirectory();

    String fileName(int fileIndex) =>
        'match_plan_${fileIndex.toString().padLeft(3, '0')}.pdf';

    int fileIndex = 0;
    List<String> existingSheetFileNames =
        matchPlanDir.listSync().map((e) => p.basename(e.path)).toList();

    while (existingSheetFileNames.contains(fileName(fileIndex))) {
      fileIndex += 1;
    }

    final String pdfFileName = fileName(fileIndex);

    final File file = File(p.join(matchPlanDir.path, pdfFileName));

    final Uint8List pdfBytes = await state.pdfDocument.value!.save();

    await file.writeAsBytes(pdfBytes);

    emit(state.copyWith(openedFile: SelectionInput.dirty(value: file)));
  }

  Future<Directory> _getPlanPdfDirectory() async {
    final Directory documentDir = await getApplicationDocumentsDirectory();
    final String matchPlanPath = p.join(
      documentDir.path,
      'ez_badminton',
      'match_plans',
    );
    final Directory matchPlanDir = Directory(matchPlanPath);
    if (!matchPlanDir.existsSync()) {
      await matchPlanDir.create(recursive: true);
    }

    return matchPlanDir;
  }
}
