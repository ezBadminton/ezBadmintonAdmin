import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/draw_management/models/badminton_match.dart';
import 'package:ez_badminton_admin_app/widgets/tournament_brackets/single_elimination_match_node.dart';
import 'package:flutter/material.dart';
import 'package:tournament_mode/tournament_mode.dart';

class SingleEliminationTree extends StatelessWidget {
  const SingleEliminationTree({
    super.key,
    required this.rounds,
    required this.competition,
  });

  final List<EliminationRound<Team, List<MatchSet>>> rounds;
  final Competition competition;

  @override
  Widget build(BuildContext context) {
    List<List<Widget>> matchNodes = [];

    for (EliminationRound<Team, List<MatchSet>> round in rounds) {
      bool isFirst = rounds.first == round;
      bool isLast = rounds.last == round;

      matchNodes.add(
        List.generate(
          round.length,
          (index) => Expanded(
            child: SingleEliminationMatchNode(
              match: round[index] as BadmintonMatch,
              teamSize: competition.teamSize,
              matchIndex: index,
              isFirstRound: isFirst,
              isLastRound: isLast,
            ),
          ),
        ),
      );
    }

    return IntrinsicHeight(
      child: Row(
        children: [
          for (List<Widget> roundNodes in matchNodes)
            Column(children: roundNodes)
        ],
      ),
    );
  }
}
