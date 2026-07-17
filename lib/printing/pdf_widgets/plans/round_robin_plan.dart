import 'dart:math';

import 'package:collection/collection.dart';
import 'package:ez_badminton_admin_app/printing/pdf_widgets/pdf_widgets.dart';
import 'package:flutter/material.dart';
import 'package:model_repository/model_repository.dart' as models;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class RoundRobinPlan extends TournamentPlan {
  RoundRobinPlan({
    required super.tPlan,
    required super.l10n,
    super.tournamentTitle,
    this.title,
  });

  final pw.Widget? title;

  bool get _isDoubles => tPlan.competition.teamSize == 2;

  @override
  List<TournamentPlanWidget> layoutPlan() {
    double rowHeight =
        _isDoubles ? groupTableDoublesHeight : groupTableSinglesHeight;
    double tableWidth = 4 * groupTableStatWidth + groupTableNameWidth;

    List<models.Team> members = tPlan.tournament.finalRanking.flattenedToList;
    List<models.MatchMetrics> metrics =
        (tPlan.tournament as models.RoundRobin).metrics;

    List<pw.Widget> rankNumbers =
        _getRankNumbers(tPlan.tournament.finalRanking);
    List<pw.Widget> winNumbers = [];
    List<pw.Widget> setNumbers = [];
    List<pw.Widget> pointNumbers = [];

    for (final metric in metrics) {
      var winText = '${metric.wins}:${metric.losses}';
      var setText = '${metric.setWins}:${metric.setLosses}';
      var pointText = '${metric.pointWins}:${metric.pointLosses}';
      winNumbers.add(pw.Text(winText, style: pw.TextStyle(fontSize: 8)));
      setNumbers.add(pw.Text(setText, style: pw.TextStyle(fontSize: 8)));
      pointNumbers.add(pw.Text(pointText, style: pw.TextStyle(fontSize: 6)));
    }

    pw.Widget headerRow = pw.SizedBox(
      height: groupTableHeaderHeight,
      child: pw.Row(children: [
        pw.SizedBox(
          width: groupTableStatWidth,
          child: pw.Center(child: pw.Text('#')),
        ),
        pw.SizedBox(
          height: groupTableHeaderHeight,
          child: pw.VerticalDivider(width: 0),
        ),
        pw.SizedBox(
          width: groupTableNameWidth,
          child: pw.Center(child: title ?? pw.Text(l10n.participant(2))),
        ),
        pw.SizedBox(
          height: groupTableHeaderHeight,
          child: pw.VerticalDivider(width: 0),
        ),
        pw.SizedBox(
          width: groupTableStatWidth,
          child: pw.Center(
            child: pw.Transform.rotateBox(
              angle: pi * 0.5,
              child: pw.Text(
                l10n.win(2),
                style: const pw.TextStyle(fontSize: 8),
              ),
            ),
          ),
        ),
        pw.SizedBox(
          height: groupTableHeaderHeight,
          child: pw.VerticalDivider(width: 0),
        ),
        pw.SizedBox(
          width: groupTableStatWidth,
          child: pw.Center(
            child: pw.Transform.rotateBox(
              angle: pi * 0.5,
              child: pw.Text(
                l10n.game(2),
                style: const pw.TextStyle(fontSize: 8),
              ),
            ),
          ),
        ),
        pw.SizedBox(
          height: groupTableHeaderHeight,
          child: pw.VerticalDivider(width: 0),
        ),
        pw.SizedBox(
          width: groupTableStatWidth,
          child: pw.Center(
            child: pw.Transform.rotateBox(
              angle: pi * 0.5,
              child: pw.Text(
                l10n.point(2),
                style: const pw.TextStyle(fontSize: 8),
              ),
            ),
          ),
        ),
      ]),
    );

    List<pw.Widget> memberRows = [
      for (final (i, team) in members.indexed) ...[
        pw.SizedBox(
          width: tableWidth,
          child: pw.Divider(height: 0),
        ),
        pw.SizedBox(
          height: rowHeight,
          child: pw.Row(children: [
            pw.SizedBox(
              width: groupTableStatWidth,
              child: pw.Center(child: rankNumbers.elementAtOrNull(i)),
            ),
            pw.SizedBox(
              height: rowHeight,
              child: pw.VerticalDivider(width: 0),
            ),
            pw.SizedBox(
              width: groupTableNameWidth,
              child: pw.Padding(
                padding: const pw.EdgeInsets.only(left: 3),
                child: SlotLabel(
                  slot: models.Slot.fromTeam(team),
                  textStyle: const pw.TextStyle(fontSize: 9),
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                ),
              ),
            ),
            pw.SizedBox(
              height: rowHeight,
              child: pw.VerticalDivider(width: 0),
            ),
            pw.SizedBox(
              width: groupTableStatWidth,
              child: pw.Center(child: winNumbers.elementAtOrNull(i)),
            ),
            pw.SizedBox(
              height: rowHeight,
              child: pw.VerticalDivider(width: 0),
            ),
            pw.SizedBox(
              width: groupTableStatWidth,
              child: pw.Center(child: setNumbers.elementAtOrNull(i)),
            ),
            pw.SizedBox(
              height: rowHeight,
              child: pw.VerticalDivider(width: 0),
            ),
            pw.SizedBox(
              width: groupTableStatWidth,
              child: pw.Center(child: pointNumbers.elementAtOrNull(i)),
            ),
          ]),
        ),
      ],
    ];

    pw.Widget memberColumn = pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border.all(),
        borderRadius: pw.BorderRadius.circular(5),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          headerRow,
          ...memberRows,
        ],
      ),
    );

    double tableHeight = members.length * rowHeight + groupTableHeaderHeight;

    TournamentPlanWidget memberTable = TournamentPlanWidget(
      boundingBox: Rect.fromLTWH(
        0,
        0,
        tableWidth,
        tableHeight,
      ),
      child: memberColumn,
    );

    pw.Widget byePlaceholder = pw.Text(
      l10n.freeOfPlay,
      style: const pw.TextStyle(
        color: PdfColors.grey600,
        fontSize: 9,
      ),
    );

    List<List<MatchCard>> roundMatchCards = [
      for (List<models.TournamentMatch> round in tPlan.tournament.rounds)
        [
          for (models.TournamentMatch match in round)
            MatchCard(
              competition: tPlan.competition,
              match: match,
              width: tableWidth,
              l10n: l10n,
              byePlaceholder: byePlaceholder,
            ),
        ]
    ];

    PdfPoint cardSize = roundMatchCards.first.first.getCardSize();

    List<TournamentPlanWidget> roundMatches = [];
    int i = 0;
    for ((int, List<MatchCard>) roundEntry in roundMatchCards.indexed) {
      int roundIndex = roundEntry.$1;
      List<MatchCard> roundCards = roundEntry.$2;

      TournamentPlanWidget roundTitle = TournamentPlanWidget(
        boundingBox: Rect.fromLTWH(
          0,
          tableHeight + i * cardSize.y + roundIndex * roundTitleHeight,
          tableWidth,
          roundTitleHeight,
        ),
        child: pw.SizedBox(
          height: roundTitleHeight,
          width: tableWidth,
          child: pw.Center(
            child: pw.Text(l10n.encounterNumber(roundIndex + 1)),
          ),
        ),
      );

      roundMatches.add(roundTitle);

      for (MatchCard card in roundCards) {
        TournamentPlanWidget planCard = TournamentPlanWidget(
          boundingBox: Rect.fromLTWH(
            0,
            tableHeight + i * cardSize.y + (roundIndex + 1) * roundTitleHeight,
            cardSize.x,
            cardSize.y,
          ),
          child: card,
        );

        roundMatches.add(planCard);

        i += 1;
      }
    }

    return [
      memberTable,
      ...roundMatches,
    ];
  }

  List<pw.Widget> _getRankNumbers(List<List<models.Team>> ranks) {
    int index = 0;
    List<pw.Widget> indices = [];
    for (List rank in ranks) {
      indices.add(pw.Text("${index + 1}."));
      for (int i = 0; i < rank.length - 1; i += 1) {
        indices.add(pw.SizedBox());
      }
      index += rank.length;
    }
    return indices;
  }
}
