import 'dart:math';

import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/badminton_tournament_ops/badminton_match.dart';
import 'package:ez_badminton_admin_app/badminton_tournament_ops/badminton_tournament_modes.dart';
import 'package:ez_badminton_admin_app/printing/pdf_widgets/pdf_widgets.dart';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:tournament_mode/tournament_mode.dart';

class RoundRobinPlan extends TournamentPlan<BadmintonRoundRobin> {
  RoundRobinPlan({
    required super.tournament,
    required super.l10n,
    this.title,
  });

  final pw.Widget? title;

  bool get _isDoubles => tournament.competition.teamSize == 2;

  @override
  List<TournamentPlanWidget> layoutPlan(BadmintonRoundRobin tournament) {
    double rowHeight =
        _isDoubles ? groupTableDoublesHeight : groupTableSinglesHeight;
    double tableWidth = 4 * groupTableStatWidth + groupTableNameWidth;

    List<MatchParticipant<Team>> members = tournament.entries.ranks
        .where((participant) => !participant.isBye)
        .toList();

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
      for (MatchParticipant<Team> participant in members) ...[
        pw.SizedBox(
          width: tableWidth,
          child: pw.Divider(height: 0),
        ),
        pw.SizedBox(
          height: rowHeight,
          child: pw.Row(children: [
            pw.SizedBox(width: groupTableStatWidth),
            pw.SizedBox(
              height: rowHeight,
              child: pw.VerticalDivider(width: 0),
            ),
            pw.SizedBox(
              width: groupTableNameWidth,
              child: pw.Padding(
                padding: const pw.EdgeInsets.only(left: 3),
                child: ParticipantLabel(
                  participant: participant,
                  textStyle: const pw.TextStyle(fontSize: 9),
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                ),
              ),
            ),
            pw.SizedBox(
              height: rowHeight,
              child: pw.VerticalDivider(width: 0),
            ),
            pw.SizedBox(width: groupTableStatWidth),
            pw.SizedBox(
              height: rowHeight,
              child: pw.VerticalDivider(width: 0),
            ),
            pw.SizedBox(width: groupTableStatWidth),
            pw.SizedBox(
              height: rowHeight,
              child: pw.VerticalDivider(width: 0),
            ),
            pw.SizedBox(width: groupTableStatWidth),
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
      for (RoundRobinRound<BadmintonMatch> round in tournament.rounds)
        [
          for (BadmintonMatch match in round.matches)
            MatchCard(
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
}
