import 'dart:math';
import 'dart:ui';

import 'package:collection/collection.dart';
import 'package:ez_badminton_admin_app/badminton_tournament_ops/badminton_tournament_modes.dart';
import 'package:ez_badminton_admin_app/printing/pdf_widgets/pdf_widgets.dart';
import 'package:ez_badminton_admin_app/printing/pdf_widgets/s_line.dart';
import 'package:ez_badminton_admin_app/printing/pdf_widgets/utils.dart';
import 'package:ez_badminton_admin_app/utils/log2/log2.dart';
import 'package:ez_badminton_admin_app/widgets/tournament_brackets/consolation_elimination_tree.dart';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:tournament_mode/tournament_mode.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ConsolationEliminationPlan
    extends TournamentPlan<BadmintonSingleEliminationWithConsolation> {
  ConsolationEliminationPlan({
    required super.tournament,
    required super.l10n,
    this.placeholders = const {},
  });

  final Map<MatchParticipant, pw.Widget> placeholders;

  @override
  List<TournamentPlanWidget> layoutPlan() {
    ConsolationTreeNode consolationTree =
        _createConsolationTree(tournament.mainBracket);

    List<TournamentPlanWidget> planWidgets = [];
    _positionBrackets(
      node: consolationTree,
      position: Offset.zero,
      rightHandSiblings: const [],
      planWidgets: planWidgets,
    );

    return planWidgets;
  }

  void _positionBrackets({
    required ConsolationTreeNode node,
    required Offset position,
    required Iterable<ConsolationTreeNode> rightHandSiblings,
    required List<TournamentPlanWidget> planWidgets,
  }) {
    PdfPoint planSize = node.plan.layoutSize();
    PdfPoint matchCardSize = (node.plan.widgets
            .firstWhere(
              (w) => (w.child is MatchCard),
            )
            .child as MatchCard)
        .getCardSize();

    TournamentPlanWidget planWidget = TournamentPlanWidget(
      boundingBox: Rect.fromLTWH(
        position.dx,
        position.dy,
        planSize.x,
        planSize.y,
      ),
      child: pw.SizedBox.fromSize(
        size: planSize,
        child: node.plan,
      ),
    );
    planWidgets.add(planWidget);

    if (node.parent != null) {
      (int, int) rankRange = node.bracket.getRankRange();
      BracketPlaceRangeText rangeText = BracketPlaceRangeText(
        upperBound: rankRange.$1 + 1,
        lowerBound: rankRange.$2 + 1,
        l10n: l10n,
      );

      TournamentPlanWidget rangeTextWidget = TournamentPlanWidget(
        boundingBox: Rect.fromLTWH(
          position.dx,
          position.dy - 20,
          planSize.x,
          35,
        ),
        child: rangeText,
      );
      planWidgets.add(rangeTextWidget);
    }

    int siblingDepth =
        rightHandSiblings.map((s) => s.getTreeDepth()).maxOrNull ?? 1;

    double verticalMargin = siblingDepth * consolationBracketVerticalMargin;

    double childrenVerticalOffset = position.dy + planSize.y + verticalMargin;
    double childrenHorizonalOffset = position.dx;

    int tournamentSize = node.bracket.bracket.rounds.first.length;
    for ((int, ConsolationTreeNode) childEntry
        in node.consolationBrackets.indexed) {
      int index = childEntry.$1;
      ConsolationTreeNode child = childEntry.$2;

      int childTournamentSize = child.bracket.bracket.rounds.first.length;

      int bracketOffset = log2(tournamentSize ~/ (2 * childTournamentSize));
      double minHorizontalOffset =
          bracketOffset * (matchCardSize.x + eliminationRoundMargin);
      double horizontalOffset =
          max(childrenHorizonalOffset, minHorizontalOffset);

      Offset childPosition = Offset(horizontalOffset, childrenVerticalOffset);

      _positionBrackets(
        node: child,
        position: childPosition,
        rightHandSiblings: node.consolationBrackets.skip(index + 1),
        planWidgets: planWidgets,
      );

      TournamentMatch dashedLineOriginMatch =
          node.bracket.bracket.rounds[bracketOffset].matches.last;
      TournamentPlanWidget dashedLineOriginWidget =
          node.plan.widgets.firstWhere(
        (w) =>
            (w.child is MatchCard) &&
            (w.child as MatchCard).match == dashedLineOriginMatch,
      );
      Offset dashedLineOrigin =
          position + dashedLineOriginWidget.boundingBox.bottomCenter;
      Offset dashedLineTarget =
          childPosition + Offset(matchCardSize.x * 0.5, 0);
      Rect dashedLineBounds = Rect.fromPoints(
        dashedLineOrigin,
        dashedLineTarget,
      );

      pw.Widget dashedLine = pw.SizedBox(
        width: dashedLineBounds.width,
        height: dashedLineBounds.height,
        child: SLine(color: PdfColors.grey400),
      );
      TournamentPlanWidget dashedLinePlanWidet = TournamentPlanWidget(
        boundingBox: dashedLineBounds,
        child: dashedLine,
      );
      planWidgets.add(dashedLinePlanWidet);

      double nextSiblingHorizontalOffset =
          horizontalOffset + child.plan.layoutSize().x + eliminationRoundMargin;

      childrenHorizonalOffset = nextSiblingHorizontalOffset;
    }
  }

  ConsolationTreeNode _createConsolationTree(
    BracketWithConsolation bracket,
  ) {
    Map<MatchParticipant, pw.Widget> placeholders = bracket.parent == null
        ? this.placeholders
        : _createConsolationPlaceholders(bracket);

    SingleEliminationPlan plan = SingleEliminationPlan(
      tournament: bracket.bracket as BadmintonSingleElimination,
      l10n: l10n,
      placeholders: placeholders,
    );

    List<ConsolationTreeNode> consolationBrackets =
        bracket.consolationBrackets.map(_createConsolationTree).toList();

    ConsolationTreeNode node = ConsolationTreeNode(
      bracket: bracket,
      plan: plan,
      consolationBrackets: consolationBrackets,
    );

    for (ConsolationTreeNode childNode in consolationBrackets) {
      childNode.parent = node;
    }

    return node;
  }

  Map<MatchParticipant, pw.Widget> _createConsolationPlaceholders(
    BracketWithConsolation bracket,
  ) {
    Map<MatchParticipant, String> labelTexts =
        ConsolationEliminationTree.createConsolationPlaceholderLabels(
      l10n,
      bracket,
    );

    Map<MatchParticipant, pw.Widget> placeholders =
        wrapPlaceholderLabels(labelTexts);

    return placeholders;
  }
}

class BracketPlaceRangeText extends pw.StatelessWidget {
  BracketPlaceRangeText({
    required this.upperBound,
    required this.lowerBound,
    this.textStyle = const pw.TextStyle(fontSize: 15),
    required this.l10n,
  });

  final int upperBound;
  final int lowerBound;

  final pw.TextStyle textStyle;

  final AppLocalizations l10n;

  @override
  pw.Widget build(pw.Context context) {
    if (upperBound == 3 && lowerBound == 4) {
      return pw.Text(l10n.matchForThrid, style: textStyle);
    }

    return pw.Text(
      l10n.upperToLowerRank(lowerBound, upperBound),
      style: textStyle,
    );
  }
}

class ConsolationTreeNode {
  ConsolationTreeNode({
    required this.bracket,
    required this.plan,
    required this.consolationBrackets,
  });

  final BracketWithConsolation bracket;
  final SingleEliminationPlan plan;

  ConsolationTreeNode? parent;

  final List<ConsolationTreeNode> consolationBrackets;

  int getTreeDepth([int depth = 0]) {
    int localDepth = depth + 1;

    int deepestChild =
        consolationBrackets.map((b) => b.getTreeDepth(localDepth)).maxOrNull ??
            localDepth;

    return deepestChild;
  }
}
