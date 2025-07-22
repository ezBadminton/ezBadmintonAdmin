// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:model_repository/model_repository.dart' as models;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'package:ez_badminton_admin_app/printing/pdf_widgets/pdf_widgets.dart';

class RoundRobinPlan extends TournamentPlan {
  RoundRobinPlan({
    required super.tPlan,
    required super.showScores,
    required super.l10n,
    this.title,
  });

  final pw.Widget? title;

  bool get _isDoubles => tPlan.competition.teamSize == 2;

  @override
  List<TournamentPlanWidget> layoutPlan() {
    double rowHeight =
        _isDoubles ? groupTableDoublesHeight : groupTableSinglesHeight;
    double tableWidth = 4 * groupTableStatWidth + groupTableNameWidth;

    List<models.Team> members = showScores
        ? tPlan.tournament.finalRanking.flattenedToList
        : tPlan.tournament.entries;
    List<models.MatchMetrics> metrics =
        (tPlan.tournament as models.RoundRobin).metrics;

    List<_GroupMemberStatTextBuilder> memberBuilders = members.mapIndexed(
      (i, team) {
        models.MatchMetrics? teamMetrics = metrics[i];
        if (!showScores || teamMetrics.numMatches == 0) {
          teamMetrics = null;
        }

        return _GroupMemberStatTextBuilder(
          team: team,
          metrics: teamMetrics,
        );
      },
    ).toList();

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
      for (final _GroupMemberStatTextBuilder member in memberBuilders) ...[
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
                child: SlotLabel(
                  slot: models.Slot.fromTeam(member.team),
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
              child: pw.Center(child: member.buildWins()),
            ),
            pw.SizedBox(
              height: rowHeight,
              child: pw.VerticalDivider(width: 0),
            ),
            pw.SizedBox(
              width: groupTableStatWidth,
              child: pw.Center(child: member.buildSets()),
            ),
            pw.SizedBox(
              height: rowHeight,
              child: pw.VerticalDivider(width: 0),
            ),
            pw.SizedBox(
              width: groupTableStatWidth,
              child: pw.Center(child: member.buildPoints()),
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
              showScore: showScores,
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

/// Builds the text widgets for the [team]'s group match [metrics] if
/// those are not null. For a team that won 2 matches and lost 1 the [buildWins]
/// method will return a text widget saying "2:1". Analog for sets and points.
class _GroupMemberStatTextBuilder {
  _GroupMemberStatTextBuilder({
    required this.team,
    this.metrics,
    // ignore: unused_element_parameter
    this.winsTextStyle = const pw.TextStyle(fontSize: 8),
    // ignore: unused_element_parameter
    this.setsTestStyle = const pw.TextStyle(fontSize: 8),
    // ignore: unused_element_parameter
    this.pointsTextStyle = const pw.TextStyle(fontSize: 6),
  });

  final models.Team team;
  final models.MatchMetrics? metrics;

  final pw.TextStyle winsTextStyle;
  final pw.TextStyle setsTestStyle;
  final pw.TextStyle pointsTextStyle;

  pw.Text? buildWins() {
    if (metrics == null) {
      return null;
    }
    final winText = '${metrics!.wins}:${metrics!.losses}';
    return pw.Text(winText, style: winsTextStyle);
  }

  pw.Text? buildSets() {
    if (metrics == null) {
      return null;
    }
    final setText = '${metrics!.setWins}:${metrics!.setLosses}';
    return pw.Text(setText, style: setsTestStyle);
  }

  pw.Text? buildPoints() {
    if (metrics == null) {
      return null;
    }
    final pointText = '${metrics!.pointWins}:${metrics!.pointLosses}';
    return pw.Text(pointText, style: pointsTextStyle);
  }
}
