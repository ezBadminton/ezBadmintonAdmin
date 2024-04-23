import 'dart:ui';

import 'package:ez_badminton_admin_app/badminton_tournament_ops/badminton_match.dart';
import 'package:ez_badminton_admin_app/badminton_tournament_ops/badminton_tournament_modes.dart';
import 'package:ez_badminton_admin_app/layout/elimination_tree/utils.dart';
import 'package:ez_badminton_admin_app/printing/pdf_widgets/bent_line.dart';
import 'package:ez_badminton_admin_app/printing/pdf_widgets/pdf_widgets.dart';
import 'package:ez_badminton_admin_app/widgets/line_painters/bent_line.dart'
    as bl;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:tournament_mode/tournament_mode.dart';

class SingleEliminationPlan extends TournamentPlan<BadmintonSingleElimination> {
  SingleEliminationPlan({
    required super.tournament,
    required super.l10n,
  });

  @override
  List<TournamentPlanWidget> layoutPlan(BadmintonSingleElimination tournament) {
    List<List<MatchCard>> matchCards = [
      for (EliminationRound<BadmintonMatch> round in tournament.rounds)
        [
          for (BadmintonMatch match in round.matches)
            MatchCard(
              match: match,
              l10n: l10n,
            )
        ],
    ];

    int numRounds = tournament.rounds.length;
    List<List<BentLine>> outgoingLines = [
      for (EliminationRound round in tournament.rounds.take(numRounds - 1))
        List.generate(
          round.matches.length,
          (index) => BentLine(
            bendCorner:
                index.isEven ? bl.Corner.topRight : bl.Corner.bottomRight,
            bendRadius: 3,
            thickness: 2,
            color: PdfColors.grey600,
          ),
        ),
      [], // Final round has no outgoing lines
    ];

    List<List<pw.Widget>> incomingLines = [
      [], // First round has no incoming lines
      for (EliminationRound round in tournament.rounds.skip(1))
        List.generate(
          round.matches.length,
          (index) => pw.Divider(
            color: PdfColors.grey600,
            height: 0,
            thickness: 2,
            indent: 0.1,
            endIndent: 1.5,
          ),
        ),
    ];

    List<TournamentPlanWidget> widgets = _positionWidgets(
      matchCards,
      outgoingLines,
      incomingLines,
    );

    return widgets;
  }

  List<TournamentPlanWidget> _positionWidgets(
    List<List<MatchCard>> matchCards,
    List<List<BentLine>> outgoingLines,
    List<List<pw.Widget>> incomingLines,
  ) {
    List<TournamentPlanWidget> planWidgets = [];

    PdfPoint cardSize = matchCards.first.first.getCardSize();
    double cardWidth = cardSize.x;
    double cardHeight = cardSize.y;

    for ((int, List<pw.Widget>) roundEntry in matchCards.indexed) {
      int roundIndex = roundEntry.$1;
      List<pw.Widget> roundCards = roundEntry.$2;

      double horizontalOffset =
          roundIndex * (cardWidth + eliminationRoundMargin);
      double horizontalLineOffset = horizontalOffset + cardWidth;

      double verticalNodeMargin = getVerticalNodeMargin(roundIndex, cardHeight);

      for ((int, pw.Widget) cardEntry in roundCards.indexed) {
        int cardIndex = cardEntry.$1;
        pw.Widget card = cardEntry.$2;

        double verticalOffset =
            getVerticalNodePosition(cardHeight, verticalNodeMargin, cardIndex);

        TournamentPlanWidget positionedCard = TournamentPlanWidget(
          boundingBox: Rect.fromLTWH(
            horizontalOffset,
            verticalOffset,
            cardWidth,
            cardHeight,
          ),
          child: card,
        );

        planWidgets.add(positionedCard);

        BentLine? bentLine = outgoingLines
            .elementAtOrNull(roundIndex)
            ?.elementAtOrNull(cardIndex);
        if (bentLine != null) {
          double lineWidth = eliminationRoundMargin * 0.5;
          double lineHeight = cardHeight * 0.5 + verticalNodeMargin * 0.5;

          double verticalLineOffset = switch (bentLine.bendCorner) {
            bl.Corner.topRight || bl.Corner.topLeft => cardHeight * 0.5,
            bl.Corner.bottomRight ||
            bl.Corner.bottomLeft =>
              -verticalNodeMargin * 0.5,
          };

          TournamentPlanWidget lineWidget = TournamentPlanWidget(
            boundingBox: Rect.fromLTWH(
              horizontalLineOffset,
              verticalOffset + verticalLineOffset,
              lineWidth,
              lineHeight,
            ),
            child: pw.SizedBox(
              width: lineWidth,
              height: lineHeight,
              child: bentLine,
            ),
          );

          planWidgets.add(lineWidget);
        }

        pw.Widget? incomingLine = incomingLines
            .elementAtOrNull(roundIndex)
            ?.elementAtOrNull(cardIndex);
        if (incomingLine != null) {
          double lineWidth = eliminationRoundMargin * 0.5;

          TournamentPlanWidget lineWidget = TournamentPlanWidget(
            boundingBox: Rect.fromLTWH(
              horizontalOffset - eliminationRoundMargin * 0.5,
              verticalOffset + cardHeight * 0.5,
              lineWidth,
              0,
            ),
            child: pw.SizedBox(
              width: lineWidth,
              height: 0,
              child: incomingLine,
            ),
          );

          planWidgets.add(lineWidget);
        }
      }
    }

    return planWidgets;
  }
}
