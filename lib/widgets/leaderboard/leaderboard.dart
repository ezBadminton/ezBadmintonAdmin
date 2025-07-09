import 'package:ez_badminton_admin_app/widgets/info_card/info_card.dart';
import 'package:ez_badminton_admin_app/widgets/tournament_brackets/slot_label.dart';
import 'package:ez_badminton_admin_app/widgets/tournament_brackets/utils.dart';
import 'package:ez_badminton_admin_app/widgets/tournament_context/tournament_context.dart';
import 'package:flutter/material.dart';
import 'package:model_repository/model_repository.dart';
import 'package:ez_badminton_admin_app/l10n/l10n.dart';

class Leaderboard extends StatelessWidget {
  const Leaderboard({super.key});

  @override
  Widget build(BuildContext context) {
    Map<Team, int?> ranks = _createTieableRanks(context);
    return RawLeaderboard(ranks: ranks);
  }

  Map<Team, int?> _createTieableRanks(BuildContext context) {
    var tournament = context.readTournament();
    var ranking = tournament.finalRanking;

    List<int> rankIndices = getRankIndices(ranking);

    Map<Team, int?> ranks = {};

    for ((int, List<Team>) rankEntry in ranking.indexed) {
      int rankIndex = rankIndices[rankEntry.$1];
      List<Team> rank = rankEntry.$2;
      for (Team participant in rank) {
        bool isFirstInRank = rank.first == participant;
        int? participantRankIndex = isFirstInRank ? rankIndex : null;

        ranks.putIfAbsent(participant, () => participantRankIndex);
      }
    }

    return ranks;
  }
}

class RawLeaderboard extends StatelessWidget {
  const RawLeaderboard({
    super.key,
    required this.ranks,
  });

  final Map<Team, int?> ranks;

  @override
  Widget build(BuildContext context) {
    List<TableRow> leaderboardEntries = [];

    for (Team team in ranks.keys) {
      TableRow row = TableRow(
        children: [
          RankNumber(rankIndex: ranks[team]),
          SlotLabel(
            Slot.fromTeam(team),
            teamSize: team.players.length,
            padding: const EdgeInsets.all(8.0),
          ),
        ],
      );

      leaderboardEntries.add(row);
    }

    return Table(
      columnWidths: const {
        0: FixedColumnWidth(42),
        1: FixedColumnWidth(370),
      },
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      border: TableBorder.all(
        color: Theme.of(context).colorScheme.onSurface.withOpacity(.2),
        borderRadius: BorderRadius.circular(10),
      ),
      children: leaderboardEntries,
    );
  }
}

class RankNumber extends StatelessWidget {
  const RankNumber({
    super.key,
    this.rankIndex,
  });

  final int? rankIndex;

  @override
  Widget build(BuildContext context) {
    TextStyle rankStyle = const TextStyle(fontWeight: FontWeight.bold);

    Widget number = rankIndex == null
        ? const SizedBox()
        : Text('${rankIndex! + 1}.', style: rankStyle);

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Align(
        alignment: AlignmentDirectional.centerEnd,
        child: number,
      ),
    );
  }
}

class ProvisionalLeaderboardInfo extends StatelessWidget {
  const ProvisionalLeaderboardInfo({super.key});

  @override
  Widget build(BuildContext context) {
    var tPlan = context.readTournamentPlan();

    if (tPlan.ended) {
      return const SizedBox();
    }

    var l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: InfoCard(child: Text(l10n.provisionalLeaderboardInfo)),
    );
  }
}
