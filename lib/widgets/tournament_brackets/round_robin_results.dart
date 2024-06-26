import 'package:collection/collection.dart';
import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/badminton_tournament_ops/badminton_match.dart';
import 'package:ez_badminton_admin_app/badminton_tournament_ops/badminton_round_robin_ranking.dart';
import 'package:ez_badminton_admin_app/badminton_tournament_ops/badminton_tournament_modes.dart';
import 'package:ez_badminton_admin_app/widgets/leaderboard/leaderboard.dart';
import 'package:ez_badminton_admin_app/widgets/match_label/match_label.dart';
import 'package:ez_badminton_admin_app/widgets/mouse_hover_builder/mouse_hover_builder.dart';
import 'package:ez_badminton_admin_app/widgets/tie_breaker_menu/tie_breaker_menu.dart';
import 'package:ez_badminton_admin_app/widgets/tournament_bracket_explorer/bracket_section_subtree.dart';
import 'package:ez_badminton_admin_app/widgets/tournament_brackets/match_participant_label.dart';
import 'package:flutter/material.dart';
import 'package:tournament_mode/tournament_mode.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class RoundRobinResults extends StatelessWidget {
  const RoundRobinResults({
    super.key,
    required this.tournament,
    this.parentTournament,
  });

  final BadmintonRoundRobin tournament;

  final BadmintonGroupKnockout? parentTournament;

  @override
  Widget build(BuildContext context) {
    return BracketSectionSubtree(
      tournamentDataObject: tournament,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _RoundRobinLeaderboard(
            tournament: tournament,
            parentTournament: parentTournament,
          ),
          const SizedBox(height: 30),
          _MatchResultList(tournament: tournament),
        ],
      ),
    );
  }
}

class _RoundRobinLeaderboard extends StatelessWidget {
  _RoundRobinLeaderboard({
    required this.tournament,
    this.parentTournament,
  }) : _brokenTieMap = _mapBrokenTies(
          tournament.finalRanking as BadmintonRoundRobinRanking,
        );

  final BadmintonRoundRobin tournament;

  final BadmintonGroupKnockout? parentTournament;

  final Map<List<Team>, List<List<Team>>> _brokenTieMap;

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;

    const TextStyle statNameStyle = TextStyle(fontSize: 11);
    TableRow leaderboardHeader = TableRow(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).disabledColor,
            width: 2,
          ),
        ),
      ),
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 14.0),
          child: Center(child: Text('#')),
        ),
        _buildTitle(context),
        Center(child: Text(l10n.match(2), style: statNameStyle)),
        Center(child: Text(l10n.win(2), style: statNameStyle)),
        Center(child: Text(l10n.game(2), style: statNameStyle)),
        Center(child: Text(l10n.point(2), style: statNameStyle)),
      ],
    );

    BadmintonRoundRobinRanking ranking =
        tournament.finalRanking as BadmintonRoundRobinRanking;

    List<List<MatchParticipant<Team>>> ranks = ranking.tiedRanks;
    List<int> rankIndicies = TieableRanking.getRankIndices(ranks);
    Map<Team, RoundRobinStats> stats = ranking.getStats();

    List<TableRow> leaderboardEntries = [];
    for ((int, List<MatchParticipant<Team>>) rankEntry in ranks.indexed) {
      int rankIndex = rankIndicies[rankEntry.$1];
      List<MatchParticipant<Team>> rank = rankEntry.$2;

      for (MatchParticipant<Team> participant in rank) {
        bool isFirstInRank = rank.first == participant;
        int? participantRankIndex = isFirstInRank ? rankIndex : null;

        Team team = participant.player!;
        RoundRobinStats teamStats = stats[team]!;

        TableRow row = TableRow(
          children: [
            RankNumber(rankIndex: participantRankIndex),
            MatchParticipantLabel(
              participant,
              teamSize: tournament.competition.teamSize,
              isEditable: false,
              padding: const EdgeInsets.all(8.0),
            ),
            _StatNumber(teamStats.numMatches),
            _DualStatNumber(teamStats.wins, teamStats.losses),
            _DualStatNumber(teamStats.setsWon, teamStats.setsLost),
            _DualStatNumber(teamStats.pointsWon, teamStats.pointsLost),
          ],
        );

        leaderboardEntries.add(row);
      }

      List<Team> tiedTeams =
          rank.map((participant) => participant.player!).toList();

      TableRow? tieBreakerRow = _buildTieBreakerRow(
        context,
        tiedTeams,
        rankIndex,
      );

      if (tieBreakerRow != null) {
        leaderboardEntries.add(tieBreakerRow);
      }
    }

    const double rankWidth = 42;
    const double teamWidth = 250;
    const double statNumberWidth = 50;
    const double dualStatNumberWidth = 70;

    return Table(
      columnWidths: const {
        0: FixedColumnWidth(rankWidth),
        1: FixedColumnWidth(teamWidth),
        2: FixedColumnWidth(statNumberWidth),
        3: FixedColumnWidth(dualStatNumberWidth),
        4: FixedColumnWidth(dualStatNumberWidth),
        5: FixedColumnWidth(dualStatNumberWidth),
      },
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      border: TableBorder.all(
        color: Theme.of(context).colorScheme.onSurface.withOpacity(.2),
        borderRadius: BorderRadius.circular(10),
      ),
      children: [
        leaderboardHeader,
        ...leaderboardEntries,
      ],
    );
  }

  Widget _buildTitle(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;

    if (parentTournament == null) {
      return const SizedBox();
    }

    int groupIndex =
        parentTournament!.groupPhase.groupRoundRobins.indexOf(tournament);

    return TableCell(
      verticalAlignment: TableCellVerticalAlignment.fill,
      child: Container(
        color: Theme.of(context).primaryColor.withOpacity(.45),
        child: Center(
          child: Text(
            l10n.groupNumber(groupIndex + 1),
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 17,
            ),
          ),
        ),
      ),
    );
  }

  TableRow? _buildTieBreakerRow(
    BuildContext context,
    List<Team> tiedTeams,
    int rankIndex,
  ) {
    if (!tournament.isCompleted()) {
      return null;
    }

    List<Team>? tieOfRank = _brokenTieMap.entries
        .firstWhereOrNull(
          (tieMapEntry) => tieMapEntry.value.last.equals(tiedTeams),
        )
        ?.key;

    if (tieOfRank == null || tieOfRank.length == 1) {
      return null;
    }

    if (parentTournament != null && parentTournament!.hasKnockoutStarted) {
      // Do not allow editing of the tie breaker when knockout phase has started
      return null;
    }

    var l10n = AppLocalizations.of(context)!;

    bool isTieBroken = tiedTeams.length == 1;

    String tieBreakerButtonLabel;
    String tieRankLabel;

    if (isTieBroken) {
      int firstRank = rankIndex - tieOfRank.length + 1;

      tieRankLabel = l10n.nthPlace('${(firstRank + 1)}-${(rankIndex + 1)}');

      tieBreakerButtonLabel = l10n.editTieBreaker;
    } else {
      tieRankLabel = l10n.nthPlace('${rankIndex + 1}');

      tieBreakerButtonLabel = l10n.breakTie;
    }

    TableRow tieBreakerRow = TableRow(
      children: [
        const SizedBox(),
        TieBreakerButton(
          competition: tournament.competition,
          tie: tieOfRank,
          tieRankLabel: tieRankLabel,
          buttonLabel: tieBreakerButtonLabel,
        ),
        const SizedBox(),
        const SizedBox(),
        const SizedBox(),
        const SizedBox(),
      ],
    );

    return tieBreakerRow;
  }

  /// Maps the ties in this [ranking] to their tie broken forms.
  ///
  /// If a tie is not broken it is mapped to itself wrapped in a
  /// one-element list.
  static Map<List<Team>, List<List<Team>>> _mapBrokenTies(
    BadmintonRoundRobinRanking ranking,
  ) {
    List<List<Team>> unbrokenTiedTanks = ranking.unbrokenTiedRanks
        .map(
          (rank) => rank
              .map((participant) => participant.player)
              .whereType<Team>()
              .toList(),
        )
        .toList();

    List<List<Team>> tiedRanks = ranking.tiedRanks
        .map(
          (rank) => rank
              .map((participant) => participant.player)
              .whereType<Team>()
              .toList(),
        )
        .toList();

    Map<List<Team>, List<List<Team>>> brokenTieMap = {};

    int offset = 0;
    for (List<Team> tie in unbrokenTiedTanks) {
      int tieSize = tie.length;

      List<List<Team>> brokenTie = [];

      while (brokenTie.flattened.length < tieSize) {
        List<Team> brokenTieEntry = tiedRanks[offset];
        brokenTie.add(brokenTieEntry);
        offset += 1;
      }

      assert(brokenTie.flattened.length == tieSize);

      brokenTieMap.putIfAbsent(tie, () => brokenTie);
    }

    return brokenTieMap;
  }
}

class _MatchResultList extends StatelessWidget {
  const _MatchResultList({
    required this.tournament,
  });

  final BadmintonRoundRobin tournament;

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        for (RoundRobinRound round in tournament.rounds) ...[
          Text(
            l10n.encounterNumber(round.roundNumber + 1),
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          for (BadmintonMatch match
              in round.matches.where((m) => !m.isBye).cast())
            MatchupCard(
              match: match,
              showResult: true,
              width: 550,
            ),
          const SizedBox(height: 10),
        ],
      ],
    );
  }
}

class _StatNumber extends StatelessWidget {
  const _StatNumber(this.number);

  final int number;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Center(child: Text('$number')),
    );
  }
}

class _DualStatNumber extends StatelessWidget {
  const _DualStatNumber(this.number1, this.number2);

  final int number1;
  final int number2;

  int get _difference => number1 - number2;

  @override
  Widget build(BuildContext context) {
    TextStyle numberStyle =
        TextStyle(color: Theme.of(context).colorScheme.onSurface);

    TextStyle colonStyle = TextStyle(color: Theme.of(context).disabledColor);

    Widget dualNumber = RichText(
      text: TextSpan(
        children: [
          TextSpan(text: '$number1', style: numberStyle),
          const WidgetSpan(child: SizedBox(width: 1)),
          TextSpan(text: ':', style: colonStyle),
          const WidgetSpan(child: SizedBox(width: 1)),
          TextSpan(text: '$number2', style: numberStyle),
        ],
      ),
    );

    Color differenceColor = switch (_difference) {
      > 0 => Colors.greenAccent.withOpacity(.4),
      < 0 => Colors.redAccent.withOpacity(.3),
      _ => Theme.of(context).colorScheme.surface,
    };
    String differenceSign = switch (_difference) {
      > 0 => '+',
      < 0 => '-',
      _ => '±',
    };
    int absDifference = _difference.abs();
    Widget difference = Text('$differenceSign$absDifference');

    return MouseHoverBuilder(
      builder: (context, isHovered) => Container(
        color: isHovered ? differenceColor : null,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Center(
            child: isHovered ? difference : dualNumber,
          ),
        ),
      ),
    );
  }
}
