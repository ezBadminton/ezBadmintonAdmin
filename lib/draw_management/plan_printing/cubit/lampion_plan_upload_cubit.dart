import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:ez_badminton_admin_app/collection_queries/collection_querier.dart';
import 'package:ez_badminton_admin_app/competition_management/models/competition_category.dart';
import 'package:ez_badminton_admin_app/printing/pdf_widgets/pdf_widgets.dart';
import 'package:ez_badminton_admin_app/printing/pdf_widgets/plans/consolation_elimination_plan.dart';
import 'package:ez_badminton_admin_app/printing/pdf_widgets/plans/double_elimination_plan.dart';
import 'package:ez_badminton_admin_app/printing/pdf_widgets/plans/group_knockout_plan.dart';
import 'package:ez_badminton_admin_app/printing/pdf_widgets/plans/round_robin_plan.dart';
import 'package:ez_badminton_admin_app/widgets/loading_screen/loading_screen.dart';
import 'package:model_repository/model_repository.dart' as models;
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:ez_badminton_admin_app/display_strings/display_strings.dart'
    as display_strings;
import 'package:http/http.dart' as http;

part 'lampion_plan_upload_state.dart';

class LampionPlanUploadCubit
    extends CollectionQuerierCubit<LampionPlanUploadState> {
  LampionPlanUploadCubit({
    required this.l10n,
    required this.uploadEndpoint,
    required models.ModelStore<models.TournamentPlan> tournamentStore,
  }) : super(
          modelStores: [tournamentStore],
          LampionPlanUploadState(),
        ) {
    bool doUpload = Platform.environment.containsKey("LAMPION_API_KEY");
    if (!doUpload) {
      return;
    }
    timer = Timer.periodic(
      const Duration(minutes: 3),
      (timer) {
        if (isClosed) {
          timer.cancel();
          return;
        }
        print("Uploading plans to Lampion App server...");
        createAndUploadPlans();
      },
    );
  }

  late final Timer timer;
  final AppLocalizations l10n;
  final models.LampionUploadEndpoint uploadEndpoint;

  @override
  void onCollectionUpdate(
    List<List<models.Model>> collections,
    models.CollectionUpdateEvent<models.Model>? updateEvent,
  ) {
    var updatedState = state.copyWith(
      loadingStatus: LoadingStatus.done,
      collections: collections,
    );
    emit(updatedState);
  }

  void createAndUploadPlans() async {
    var startedPlans = state
        .getCollection<models.TournamentPlan>()
        .where((plan) => plan.started)
        .toList();

    for (final tPlan in startedPlans) {
      var competitionAbbreviation =
          display_strings.competitionDisciplineAbbreviation(
        l10n,
        CompetitionDiscipline.fromCompetition(tPlan.competition),
      );
      if (competitionAbbreviation == "MX") {
        competitionAbbreviation = "MD";
      }

      String levelAbbreviation = tPlan.competition.playingLevel?.name ?? "";
      if (levelAbbreviation.isNotEmpty) {
        levelAbbreviation = levelAbbreviation.substring(
          levelAbbreviation.length - 1,
        );
      }
      competitionAbbreviation = "$competitionAbbreviation-$levelAbbreviation";

      final pdf = pw.Document();

      TournamentPlan plan = switch (tPlan.tournament) {
        models.SingleElimination _ => SingleEliminationPlan(
            tPlan: tPlan,
            l10n: l10n,
          ),
        models.RoundRobin _ => RoundRobinPlan(
            tPlan: tPlan,
            l10n: l10n,
          ),
        models.DoubleElimination _ => DoubleEliminationPlan(
            tPlan: tPlan,
            l10n: l10n,
          ),
        models.SingleEliminationWithConsolation _ => ConsolationEliminationPlan(
            tPlan: tPlan,
            l10n: l10n,
          ),
        models.GroupKnockout _ => GroupKnockOutPlan(
            tPlan: tPlan,
            l10n: l10n,
          ),
      };

      List<pw.Page> pages = plan.generatePdfPages(bigPage: true);

      for (pw.Page page in pages) {
        pdf.addPage(page);
      }

      final Uint8List pdfBytes = await pdf.save();

      final filename = "$competitionAbbreviation.pdf";
      final mpFile = http.MultipartFile.fromBytes(
        "sheet",
        pdfBytes.toList(),
        filename: filename,
      );
      await uploadEndpoint.postFiles([mpFile]);
    }
  }

  @override
  Future<void> close() {
    timer.cancel();
    return super.close();
  }
}
