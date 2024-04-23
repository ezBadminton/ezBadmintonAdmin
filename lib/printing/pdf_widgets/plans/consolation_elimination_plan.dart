import 'dart:math';
import 'dart:ui';

import 'package:collection/collection.dart';
import 'package:dart_numerics/dart_numerics.dart';
import 'package:ez_badminton_admin_app/badminton_tournament_ops/badminton_tournament_modes.dart';
import 'package:ez_badminton_admin_app/printing/pdf_widgets/pdf_widgets.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:tournament_mode/tournament_mode.dart';

class ConsolationEliminationPlan
    extends TournamentPlan<BadmintonSingleEliminationWithConsolation> {
  ConsolationEliminationPlan({
    required super.tournament,
    required super.l10n,
  });

  @override
  List<TournamentPlanWidget> layoutPlan(
    BadmintonSingleEliminationWithConsolation tournament,
  ) {
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

      double nextSiblingHorizontalOffset =
          horizontalOffset + child.plan.layoutSize().x + eliminationRoundMargin;

      childrenHorizonalOffset = nextSiblingHorizontalOffset;
    }
  }

  ConsolationTreeNode _createConsolationTree(
    BracketWithConsolation bracket,
  ) {
    SingleEliminationPlan plan = SingleEliminationPlan(
      tournament: bracket.bracket as BadmintonSingleElimination,
      l10n: l10n,
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
