import 'dart:math';

import 'package:ez_badminton_admin_app/layout/elimination_tree/utils.dart';
import 'package:ez_badminton_admin_app/printing/pdf_widgets/bent_line.dart';
import 'package:ez_badminton_admin_app/printing/pdf_widgets/pdf_widgets.dart';
import 'package:ez_badminton_admin_app/printing/pdf_widgets/s_line.dart';
import 'package:ez_badminton_admin_app/printing/pdf_widgets/utils.dart';
import 'package:ez_badminton_admin_app/widgets/line_painters/bent_line.dart'
    as bl;
import 'package:ez_badminton_admin_app/widgets/tournament_brackets/double_elimination_tree.dart';
import 'package:flutter/material.dart';
import 'package:model_repository/model_repository.dart' as models;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class DoubleEliminationPlan extends TournamentPlan<models.DoubleElimination> {
  DoubleEliminationPlan({
    required super.tPlan,
    required super.showScores,
    required super.l10n,
    this.placeholders = const {},
  });

  models.DoubleElimination get tournament =>
      tPlan.tournament as models.DoubleElimination;
  final Map<models.Slot, pw.Widget> placeholders;

  @override
  List<TournamentPlanWidget> layoutPlan() {
    SingleEliminationPlan winnerBracket = SingleEliminationPlan(
      tPlan: tPlan,
      rounds: tournament.winnerRounds,
      showScores: showScores,
      l10n: l10n,
      placeholders: placeholders,
    );

    PdfPoint winnerBracketSize = winnerBracket.layoutSize();

    List<TournamentPlanWidget> planWidgets = [];

    TournamentPlanWidget winnerBracketPlan = TournamentPlanWidget(
      boundingBox: Rect.fromLTWH(
        0,
        0,
        winnerBracketSize.x,
        winnerBracketSize.y,
      ),
      child: pw.SizedBox.fromSize(
        size: winnerBracketSize,
        child: winnerBracket,
      ),
    );
    planWidgets.add(winnerBracketPlan);

    Map<models.Slot, pw.Widget> loserPlaceholders = _createPlaceholderLabels();

    List<List<MatchCard>> loserMatches = tournament.loserRounds
        .map((loserRound) => [
              for (models.TournamentMatch match in loserRound)
                MatchCard(
                  competition: tPlan.competition,
                  match: match,
                  showScore: showScores,
                  l10n: l10n,
                  placeholders: loserPlaceholders,
                ),
            ])
        .toList();

    List<TournamentPlanWidget> loserPlanWidgets = _positionLoserBracketMatches(
      loserMatches,
      winnerBracket,
    );

    planWidgets.addAll(loserPlanWidgets);

    return planWidgets;
  }

  List<TournamentPlanWidget> _positionLoserBracketMatches(
    List<List<MatchCard>> matchCards,
    SingleEliminationPlan winnerBracket,
  ) {
    PdfPoint winnerBracketSize = winnerBracket.layoutSize();
    PdfPoint cardSize = matchCards.first.first.getCardSize();

    List<TournamentPlanWidget> matchPlanWidgets = [];

    for ((int, List<MatchCard>) roundEntry in matchCards.indexed) {
      int roundIndex = roundEntry.$1;
      List<MatchCard> roundMatchCards = roundEntry.$2;

      double verticalNodeMargin = getVerticalNodeMargin(
        roundIndex ~/ 2,
        cardSize.y,
      );

      double horizontalNodeOffset =
          (cardSize.x + eliminationRoundMargin) * roundIndex;

      for ((int, MatchCard) matchCardEntry in roundMatchCards.indexed) {
        int index = matchCardEntry.$1;
        MatchCard card = matchCardEntry.$2;

        double verticalNodeOffset = getVerticalLoserBracketNodePosition(
          verticalNodeMargin,
          roundIndex,
          index,
          Size(winnerBracketSize.x, winnerBracketSize.y),
          Size(cardSize.x, cardSize.y),
          loserBracketMargin,
        );

        TournamentPlanWidget matchWidget = TournamentPlanWidget(
          boundingBox: Rect.fromLTWH(
            horizontalNodeOffset,
            verticalNodeOffset,
            cardSize.x,
            cardSize.y,
          ),
          child: card,
        );
        matchPlanWidgets.add(matchWidget);

        if (roundIndex.isEven) {
          if (roundIndex > 0) {
            TournamentPlanWidget incomingLine = TournamentPlanWidget(
              boundingBox: Rect.fromLTWH(
                horizontalNodeOffset - 0.5 * eliminationRoundMargin,
                verticalNodeOffset + 0.5 * cardSize.y,
                0.5 * eliminationRoundMargin,
                0,
              ),
              child: pw.SizedBox(
                width: 0.5 * eliminationRoundMargin,
                child: pw.Divider(
                  color: PdfColors.grey600,
                  height: 0,
                  thickness: 2,
                  indent: 0.1,
                  endIndent: 1.5,
                ),
              ),
            );
            matchPlanWidgets.add(incomingLine);
          }

          if (roundIndex < matchCards.length - 1) {
            TournamentPlanWidget outgoingLine = TournamentPlanWidget(
              boundingBox: Rect.fromLTWH(
                horizontalNodeOffset + cardSize.x,
                verticalNodeOffset + 0.5 * cardSize.y,
                eliminationRoundMargin,
                0,
              ),
              child: pw.SizedBox(
                width: eliminationRoundMargin,
                child: pw.Divider(
                  color: PdfColors.grey600,
                  height: 0,
                  thickness: 2,
                  indent: 1.5,
                  endIndent: 1.5,
                ),
              ),
            );
            matchPlanWidgets.add(outgoingLine);
          }
        } else if (roundIndex < matchCards.length - 1) {
          double lineWidth = eliminationRoundMargin * 0.5;
          double lineHeight = cardSize.y * 0.5 + verticalNodeMargin * 0.5;

          double verticalLineOffset =
              index.isEven ? cardSize.y * 0.5 : -verticalNodeMargin * 0.5;

          TournamentPlanWidget outgoingLine = TournamentPlanWidget(
            boundingBox: Rect.fromLTWH(
              horizontalNodeOffset + cardSize.x,
              verticalNodeOffset + verticalLineOffset,
              lineWidth,
              lineHeight,
            ),
            child: pw.SizedBox(
              width: lineWidth,
              height: lineHeight,
              child: BentLine(
                bendCorner:
                    index.isEven ? bl.Corner.topRight : bl.Corner.bottomRight,
                bendRadius: 3,
                thickness: 2,
                color: PdfColors.grey600,
              ),
            ),
          );
          matchPlanWidgets.add(outgoingLine);
        }
      }
    }

    TournamentPlanWidget upperFinal =
        winnerBracket.widgets.reversed.firstWhere((w) => w.child is MatchCard);
    TournamentPlanWidget lowerFinal =
        matchPlanWidgets.reversed.firstWhere((w) => w.child is MatchCard);

    MatchCard finalMatchCard = MatchCard(
      competition: tPlan.competition,
      match: tournament.finalMatch,
      showScore: showScores,
      l10n: l10n,
    );

    List<TournamentPlanWidget> finalWidgets =
        _positionFinalMatch(finalMatchCard, upperFinal, lowerFinal);
    matchPlanWidgets.addAll(finalWidgets);

    List<TournamentPlanWidget> dashedLines =
        _positionDashedLines(winnerBracket, matchPlanWidgets);
    matchPlanWidgets.addAll(dashedLines);

    return matchPlanWidgets;
  }

  List<TournamentPlanWidget> _positionFinalMatch(
    MatchCard finalMatchCard,
    TournamentPlanWidget upperFinalWidget,
    TournamentPlanWidget lowerFinalWidget,
  ) {
    PdfPoint cardSize = finalMatchCard.getCardSize();

    double horizontalNodeOffset =
        lowerFinalWidget.boundingBox.right + eliminationRoundMargin;

    double verticalNodeOffset =
        (lowerFinalWidget.boundingBox.top + upperFinalWidget.boundingBox.top) *
            0.5;

    TournamentPlanWidget finalMatchWidget = TournamentPlanWidget(
      boundingBox: Rect.fromLTWH(
        horizontalNodeOffset,
        verticalNodeOffset,
        cardSize.x,
        cardSize.y,
      ),
      child: finalMatchCard,
    );

    double lineWidth = eliminationRoundMargin * 0.5;

    TournamentPlanWidget incomingLine = TournamentPlanWidget(
      boundingBox: Rect.fromLTWH(
        horizontalNodeOffset - eliminationRoundMargin * 0.5,
        verticalNodeOffset + cardSize.y * 0.5,
        lineWidth,
        0,
      ),
      child: pw.SizedBox(
        width: lineWidth,
        child: pw.Divider(
          color: PdfColors.grey600,
          height: 0,
          thickness: 2,
          indent: 0.1,
          endIndent: 1.5,
        ),
      ),
    );

    double lineHeight =
        (lowerFinalWidget.boundingBox.top - upperFinalWidget.boundingBox.top) *
            0.5;
    lineWidth = horizontalNodeOffset -
        upperFinalWidget.boundingBox.right -
        eliminationRoundMargin * 0.5;

    TournamentPlanWidget upperOutgoingLine = TournamentPlanWidget(
      boundingBox: Rect.fromLTWH(
        upperFinalWidget.boundingBox.right,
        upperFinalWidget.boundingBox.top + cardSize.y * 0.5,
        lineWidth,
        lineHeight,
      ),
      child: pw.SizedBox(
        width: lineWidth,
        height: lineHeight,
        child: BentLine(
          bendCorner: bl.Corner.topRight,
          bendRadius: 3,
          thickness: 2,
          color: PdfColors.grey600,
        ),
      ),
    );

    lineWidth = horizontalNodeOffset -
        lowerFinalWidget.boundingBox.right -
        eliminationRoundMargin * 0.5;

    TournamentPlanWidget lowerOutgoingLine = TournamentPlanWidget(
      boundingBox: Rect.fromLTWH(
        horizontalNodeOffset - eliminationRoundMargin,
        lowerFinalWidget.boundingBox.center.dy - lineHeight,
        lineWidth,
        lineHeight,
      ),
      child: pw.SizedBox(
        width: lineWidth,
        height: lineHeight,
        child: BentLine(
          bendCorner: bl.Corner.bottomRight,
          bendRadius: 3,
          thickness: 2,
          color: PdfColors.grey600,
        ),
      ),
    );

    return [
      finalMatchWidget,
      incomingLine,
      upperOutgoingLine,
      lowerOutgoingLine,
    ];
  }

  List<TournamentPlanWidget> _positionDashedLines(
    SingleEliminationPlan winnerBracket,
    List<TournamentPlanWidget> loserBracketWidgets,
  ) {
    var dashedLines = <TournamentPlanWidget>[];
    for (final (i, round) in tournament.winnerRounds.indexed) {
      var dashedLineOriginMatch = round.last;
      var dashedLineOriginWidget = winnerBracket.widgets.firstWhere(
        (w) =>
            (w.child is MatchCard) &&
            (w.child as MatchCard).match == dashedLineOriginMatch,
      );

      var loserRoundI = max(0, 2 * (i - 1) + 1);
      var dashedLineTargetMatch = tournament.loserRounds[loserRoundI].first;
      var dashedLineTargetWidget = loserBracketWidgets.firstWhere(
        (w) =>
            (w.child is MatchCard) &&
            (w.child as MatchCard).match == dashedLineTargetMatch,
      );

      Rect boundingBox = Rect.fromPoints(
        dashedLineOriginWidget.boundingBox.bottomCenter,
        dashedLineTargetWidget.boundingBox.topCenter,
      );

      var dashedLine = TournamentPlanWidget(
        boundingBox: boundingBox,
        child: pw.SizedBox.fromSize(
          size: PdfPoint(boundingBox.size.width, boundingBox.size.height),
          child: SLine(color: PdfColors.grey400),
        ),
      );

      dashedLines.add(dashedLine);
    }
    return dashedLines;
  }

  Map<models.Slot, pw.Widget> _createPlaceholderLabels() {
    Map<models.Slot, String> labelTexts =
        DoubleEliminationTree.createPlaceholderLabels(tournament, l10n);

    Map<models.Slot, pw.Widget> labels = wrapPlaceholderLabels(labelTexts);

    return labels;
  }
}
