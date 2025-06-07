import 'package:collection/collection.dart';
import 'package:ez_badminton_admin_app/widgets/leaderboard/leaderboard.dart';
import 'package:ez_badminton_admin_app/widgets/match_label/match_label.dart';
import 'package:ez_badminton_admin_app/widgets/mouse_hover_builder/mouse_hover_builder.dart';
import 'package:ez_badminton_admin_app/widgets/tie_breaker_menu/tie_breaker_menu.dart';
import 'package:ez_badminton_admin_app/widgets/tournament_bracket_explorer/bracket_section_subtree.dart';
import 'package:ez_badminton_admin_app/widgets/tournament_brackets/slot_label.dart';
import 'package:ez_badminton_admin_app/widgets/tournament_brackets/utils.dart';
import 'package:ez_badminton_admin_app/widgets/tournament_context/tournament_context.dart';
import 'package:flutter/material.dart';
import 'package:ez_badminton_admin_app/l10n/l10n.dart';
import 'package:model_repository/model_repository.dart';

class RoundRobinResults extends StatelessWidget {
  const RoundRobinResults({super.key});

  @override
  Widget build(BuildContext context) {
    return BracketSectionSubtree(
      tournamentDataObject: context.readTournament(),
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _RoundRobinLeaderboard(),
          SizedBox(height: 30),
          _MatchResultList(),
        ],
      ),
    );
  }
}

class _RoundRobinLeaderboard extends StatelessWidget {
  const _RoundRobinLeaderboard();

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;

    var tournament = context.readTournament() as RoundRobin;

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

    List<List<Team>> ranks = tournament.finalRanking;
    List<int> rankIndices = getRankIndices(ranks);
    List<MatchMetrics> metrics = tournament.metrics;

    var stats = <Team, MatchMetrics>{};
    ranks.flattened.forEachIndexed((i, team) {
      stats[team] = metrics[i];
    });

    List<TableRow> leaderboardEntries = [];
    for ((int, List<Team>) rankEntry in ranks.indexed) {
      int rankIndex = rankIndices[rankEntry.$1];
      List<Team> rank = rankEntry.$2;

      for (Team team in rank) {
        bool isFirstInRank = rank.first == team;
        int? teamRankIndex = isFirstInRank ? rankIndex : null;

        MatchMetrics teamStats = stats[team]!;

        TableRow row = TableRow(
          children: [
            RankNumber(rankIndex: teamRankIndex),
            SlotLabel(
              Slot.fromTeam(team),
              teamSize: team.players.length,
              isEditable: false,
              padding: const EdgeInsets.all(8.0),
            ),
            _StatNumber(teamStats.numMatches),
            _DualStatNumber(teamStats.wins, teamStats.losses),
            _DualStatNumber(teamStats.setWins, teamStats.setLosses),
            _DualStatNumber(teamStats.pointWins, teamStats.pointLosses),
          ],
        );

        leaderboardEntries.add(row);
      }

      TableRow? tieBreakerRow = _buildTieBreakerRow(
        context,
        rank,
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

    var tPlan = context.readTournamentPlan();
    var tournament = context.readTournament() as RoundRobin;

    GroupKnockout? parentTournament;
    if (tPlan.tournament is GroupKnockout) {
      parentTournament = tPlan.tournament as GroupKnockout;
    }

    if (parentTournament == null) {
      return const SizedBox();
    }

    int groupIndex = parentTournament.groupPhase.groups.indexOf(tournament);

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
    var tPlan = context.readTournamentPlan();
    var tournament = context.readTournament() as RoundRobin;

    GroupKnockout? parentTournament;
    if (tPlan.tournament is GroupKnockout) {
      parentTournament = tPlan.tournament as GroupKnockout;
    }

    List<Team>? tieOfRank = tournament.unbrokenTies.firstWhereOrNull(
      (tie) => tie.last == tiedTeams.last,
    );

    if (tieOfRank == null || tieOfRank.length == 1) {
      return null;
    }

    if (parentTournament != null) {
      var groups = parentTournament.groupPhase.groups;
      if (parentTournament.knockoutStarted ||
          groups.map((g) => g.matchesEnded).contains(false)) {
        return null;
      }
    } else {
      if (!tournament.matchesEnded) {
        return null;
      }
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
          competition: tPlan.competition,
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
}

class _MatchResultList extends StatelessWidget {
  const _MatchResultList();

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;

    var tournament = context.readTournament();

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        for (var (i, round) in tournament.rounds.indexed) ...[
          Text(
            l10n.encounterNumber(i + 1),
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          for (TournamentMatch match in round.where((m) => !m.isBye))
            MatchContextSubtree(
              key: ValueKey('RoundRobinResultMatch-${match.id}'),
              match: match,
              child: MatchupCard(
                showResult: true,
                width: 550,
              ),
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
