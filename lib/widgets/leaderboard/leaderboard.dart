import 'package:collection/collection.dart';
import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/widgets/tournament_brackets/match_participant_label.dart';
import 'package:flutter/material.dart';
import 'package:tournament_mode/tournament_mode.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class Leaderboard extends StatelessWidget {
  const Leaderboard({
    super.key,
    required this.ranking,
  });

  final Ranking<Team> ranking;

  @override
  Widget build(BuildContext context) {
    Map<MatchParticipant<Team>, int?> ranks = switch (ranking) {
      TieableRanking<Team> _ => _createTieableRanks(),
      _ => _createRanks(),
    };

    return RawLeaderboard(ranks: ranks);
  }

  Map<MatchParticipant<Team>, int?> _createRanks() {
    List<MatchParticipant<Team>> rankList = ranking.rank();

    Map<MatchParticipant<Team>, int?> ranks = Map.fromEntries(
      rankList.mapIndexed((index, participant) => MapEntry(participant, index)),
    );

    return ranks;
  }

  Map<MatchParticipant<Team>, int?> _createTieableRanks() {
    List<List<MatchParticipant<Team>>> rankList =
        (ranking as TieableRanking<Team>).tiedRank();

    List<int> rankIndices = TieableRanking.getRankIndices(rankList);

    Map<MatchParticipant<Team>, int?> ranks = {};

    for ((int, List<MatchParticipant<Team>>) rankEntry in rankList.indexed) {
      int rankIndex = rankIndices[rankEntry.$1];
      List<MatchParticipant<Team>> rank = rankEntry.$2;
      for (MatchParticipant<Team> participant in rank) {
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

  final Map<MatchParticipant<Team>, int?> ranks;

  @override
  Widget build(BuildContext context) {
    List<TableRow> leaderboardEntries = [];

    for (MatchParticipant<Team> participant in ranks.keys) {
      Team team = participant.resolvePlayer()!;

      TableRow row = TableRow(
        children: [
          RankNumber(rankIndex: ranks[participant]),
          MatchParticipantLabel(
            participant,
            teamSize: team.players.length,
            isEditable: false,
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
  const ProvisionalLeaderboardInfo({
    super.key,
    required this.tournament,
  });

  final TournamentMode tournament;

  @override
  Widget build(BuildContext context) {
    bool isTournamentCompleted = tournament.isCompleted();

    if (isTournamentCompleted) {
      return const SizedBox();
    }

    var l10n = AppLocalizations.of(context)!;

    return Card(
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.only(bottom: 15.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
        side: BorderSide(
          color: Theme.of(context).colorScheme.onSurface.withOpacity(.3),
          width: 2,
        ),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            SizedBox(
              width: 35,
              child: SizedBox.expand(
                child: Container(
                  color: Theme.of(context).primaryColor.withOpacity(.33),
                  child: const Icon(Icons.info_outline),
                ),
              ),
            ),
            Expanded(
              child: Container(
                width: 380,
                color: Theme.of(context).primaryColor.withOpacity(.1),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Text(l10n.provisionalLeaderboardInfo),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
