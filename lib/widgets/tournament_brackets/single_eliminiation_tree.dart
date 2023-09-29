import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/badminton_tournament_ops/badminton_match.dart';
import 'package:ez_badminton_admin_app/draw_management/cubit/draw_editing_cubit.dart';
import 'package:ez_badminton_admin_app/widgets/tournament_brackets/single_elimination_match_node.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:local_hero/local_hero.dart';
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
    List<List<Widget>> roundNodes = [];

    for (EliminationRound<Team, List<MatchSet>> round in rounds) {
      bool isFirst = rounds.first == round;
      bool isLast = rounds.last == round;

      roundNodes.add(
        List.generate(
          round.length,
          (index) => Expanded(
            child: SingleEliminationMatchNode(
              match: round[index] as BadmintonMatch,
              teamSize: competition.teamSize,
              matchIndex: index,
              isFirstRound: isFirst,
              isLastRound: isLast,
              isEditable: true,
            ),
          ),
        ),
      );
    }

    return BlocProvider(
      key: ValueKey<String>('DrawEditingCubit${competition.id}'),
      create: (context) => DrawEditingCubit(
        competition: competition,
        competitionRepository:
            context.read<CollectionRepository<Competition>>(),
      ),
      child: LocalHeroScope(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutQuad,
        child: IntrinsicHeight(
          child: Row(
            children: [
              for (List<Widget> matchNodes in roundNodes)
                Column(children: matchNodes)
            ],
          ),
        ),
      ),
    );
  }
}
