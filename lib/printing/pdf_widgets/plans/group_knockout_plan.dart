import 'dart:ui';

import 'package:collection/collection.dart';
import 'package:ez_badminton_admin_app/printing/pdf_widgets/pdf_widgets.dart';
import 'package:ez_badminton_admin_app/printing/pdf_widgets/plans/consolation_elimination_plan.dart';
import 'package:ez_badminton_admin_app/printing/pdf_widgets/plans/double_elimination_plan.dart';
import 'package:ez_badminton_admin_app/printing/pdf_widgets/plans/round_robin_plan.dart';
import 'package:ez_badminton_admin_app/printing/pdf_widgets/utils.dart';
import 'package:model_repository/model_repository.dart' as models;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:ez_badminton_admin_app/widgets/tournament_brackets/group_knockout_plan.dart'
    as ko_plan;

class GroupKnockOutPlan extends TournamentPlan<models.GroupKnockout> {
  GroupKnockOutPlan({
    required super.tPlan,
    required super.l10n,
  });

  models.GroupKnockout get tournament =>
      tPlan.tournament as models.GroupKnockout;

  @override
  List<TournamentPlanWidget> layoutPlan() {
    List<TournamentPlanWidget> planWidgets = [];

    List<TournamentPlanWidget> groupPlans = _positionGroups();
    planWidgets.addAll(groupPlans);

    TournamentPlanWidget knockOutPlan = _positionKnockOutPlan(groupPlans.last);
    planWidgets.add(knockOutPlan);

    return planWidgets;
  }

  List<TournamentPlanWidget> _positionGroups() {
    List<models.RoundRobin> groups = tournament.groupPhase.groups;

    List<RoundRobinPlan> groupPlans = groups
        .mapIndexed((index, g) => RoundRobinPlan(
              tPlan: tPlan,
              title: pw.Text(l10n.groupNumber(index + 1)),
              l10n: l10n,
            ))
        .toList();

    List<TournamentPlanWidget> groupPlanWidgets =
        groupPlans.mapIndexed((index, p) {
      PdfPoint groupPlanSize = p.layoutSize();

      double horizontalOffset =
          index * (groupPlanSize.x + eliminationRoundMargin);

      TournamentPlanWidget planWidget = TournamentPlanWidget(
        boundingBox: Rect.fromLTWH(
          horizontalOffset,
          0,
          groupPlanSize.x,
          groupPlanSize.y,
        ),
        child: pw.SizedBox.fromSize(
          size: groupPlanSize,
          child: p,
        ),
      );

      return planWidget;
    }).toList();

    return groupPlanWidgets;
  }

  TournamentPlanWidget _positionKnockOutPlan(
    TournamentPlanWidget lastGroup,
  ) {
    double horizontalOffset =
        lastGroup.boundingBox.right + 2 * eliminationRoundMargin;

    Map<models.Slot, pw.Widget> placeholders = _createPlaceholders();
    TournamentPlan knockOutPlan = switch (tournament.knockoutPhase) {
      models.SingleElimination singleElimination => SingleEliminationPlan(
          tPlan: tPlan.copyWith(tournament: singleElimination),
          l10n: l10n,
          placeholders: placeholders,
        ),
      models.DoubleElimination doubleElimination => DoubleEliminationPlan(
          tPlan: tPlan.copyWith(tournament: doubleElimination),
          l10n: l10n,
          placeholders: placeholders,
        ),
      models.SingleEliminationWithConsolation consolationElimination =>
        ConsolationEliminationPlan(
          tPlan: tPlan.copyWith(tournament: consolationElimination),
          l10n: l10n,
          placeholders: placeholders,
        ),
      _ => throw Exception("This knock-out tournament has no plan implemented"),
    } as TournamentPlan;

    PdfPoint planSize = knockOutPlan.layoutSize();

    TournamentPlanWidget planWidget = TournamentPlanWidget(
      boundingBox: Rect.fromLTWH(
        horizontalOffset,
        0,
        planSize.x,
        planSize.y,
      ),
      child: pw.SizedBox.fromSize(
        size: planSize,
        child: knockOutPlan,
      ),
    );

    return planWidget;
  }

  Map<models.Slot, pw.Widget> _createPlaceholders() {
    Map<models.Slot, String> labelTexts =
        ko_plan.GroupKnockoutPlan.createQualificationPlaceholderTexts(
      tournament,
      tPlan.competition,
      l10n,
    );

    Map<models.Slot, pw.Widget> placeholders =
        wrapPlaceholderLabels(labelTexts);

    return placeholders;
  }
}
