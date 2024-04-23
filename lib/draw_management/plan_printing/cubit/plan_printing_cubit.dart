import 'dart:io';
import 'dart:typed_data';

import 'package:bloc/bloc.dart';
import 'package:ez_badminton_admin_app/badminton_tournament_ops/badminton_tournament_modes.dart';
import 'package:ez_badminton_admin_app/input_models/models.dart';
import 'package:ez_badminton_admin_app/printing/pdf_printing_cubit.dart';
import 'package:ez_badminton_admin_app/printing/pdf_widgets/pdf_widgets.dart';
import 'package:ez_badminton_admin_app/printing/pdf_widgets/plans/consolation_elimination_plan.dart';
import 'package:ez_badminton_admin_app/printing/pdf_widgets/plans/double_elimination_plan.dart';
import 'package:ez_badminton_admin_app/printing/pdf_widgets/plans/group_knockout_plan.dart';
import 'package:ez_badminton_admin_app/printing/pdf_widgets/plans/round_robin_plan.dart';
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

  void printBigPageToggled() {
    emit(state.copyWith(printBigPage: !state.printBigPage));
    _generatePdf();
  }

  @override
  void pdfOpened() {
    _saveAndOpenPdf();
  }

  @override
  void saveLocationOpened() async {
    Directory saveLocation = await getSaveLocationDir();

    emit(state.copyWith(
      openedDirectory: SelectionInput.dirty(value: saveLocation),
    ));
  }

  void _generatePdf() {
    if (state.tournaments.isEmpty) {
      emit(state.copyWith(pdfDocument: const SelectionInput.dirty()));
      return;
    }

    final pdf = pw.Document();

    List<TournamentPlan> plans = state.tournaments.map((t) {
      TournamentPlan plan = switch (t) {
        BadmintonSingleElimination singleElimination => SingleEliminationPlan(
            tournament: singleElimination,
            l10n: l10n,
          ),
        BadmintonRoundRobin roundRobin => RoundRobinPlan(
            tournament: roundRobin,
            l10n: l10n,
          ),
        BadmintonDoubleElimination doubleElimination => DoubleEliminationPlan(
            tournament: doubleElimination,
            l10n: l10n,
          ),
        BadmintonSingleEliminationWithConsolation consolationElimination =>
          ConsolationEliminationPlan(
            tournament: consolationElimination,
            l10n: l10n,
          ),
        BadmintonGroupKnockout groupKnockOut => GroupKnockOutPlan(
            tournament: groupKnockOut,
            l10n: l10n,
          ),
        _ => throw Exception("This mode has no plan implemented!"),
      } as TournamentPlan;

      return plan;
    }).toList();

    List<pw.Page> pages = plans
        .expand(
          (p) => p.generatePdfPages(bigPage: state.printBigPage),
        )
        .toList();

    for (pw.Page page in pages) {
      pdf.addPage(page);
    }

    emit(state.copyWith(
      pdfDocument: SelectionInput.dirty(value: pdf),
    ));
  }

  void _saveAndOpenPdf() async {
    if (state.pdfDocument.value == null) {
      return;
    }

    Directory matchPlanDir = await getSaveLocationDir();

    final String pdfFileName = getPdfFileName(
      (fileIndex) => 'match_plan_${fileIndex.toString().padLeft(3, '0')}.pdf',
      matchPlanDir,
    );

    final File file = File(p.join(matchPlanDir.path, pdfFileName));

    final Uint8List pdfBytes = await state.pdfDocument.value!.save();

    await file.writeAsBytes(pdfBytes);

    emit(state.copyWith(openedFile: SelectionInput.dirty(value: file)));
  }

  @override
  Future<Directory> getSaveLocationDir() async {
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
