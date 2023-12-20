import 'package:ez_badminton_admin_app/badminton_tournament_ops/badminton_tournament_modes.dart';
import 'package:ez_badminton_admin_app/widgets/tournament_bracket_explorer/bracket_section.dart';
import 'package:ez_badminton_admin_app/widgets/tournament_brackets/group_knockout_plan.dart';
import 'package:ez_badminton_admin_app/widgets/tournament_brackets/round_robin_results.dart';
import 'package:ez_badminton_admin_app/widgets/tournament_brackets/sectioned_bracket.dart';
import 'package:ez_badminton_admin_app/widgets/tournament_brackets/single_eliminiation_tree.dart';
import 'package:flutter/material.dart';
import 'bracket_sizes.dart' as bracket_sizes;

class GroupKnockoutResults extends StatelessWidget implements SectionedBracket {
  GroupKnockoutResults({
    super.key,
    required this.tournament,
  }) : _sections = GroupKnockoutPlan.getSections(tournament);

  final BadmintonGroupKnockout tournament;

  final List<BracketSection> _sections;
  @override
  List<BracketSection> get sections => _sections;

  @override
  Widget build(BuildContext context) {
    List<BadmintonRoundRobin> groupRoundRobins =
        tournament.groupPhase.groupRoundRobins;

    List<Widget> groupResults = groupRoundRobins
        .map(
          (g) => RoundRobinResults(tournament: g, parentTournament: tournament),
        )
        .toList();

    Widget eliminationTree = SingleEliminationTree(
      rounds: tournament.knockoutPhase.rounds,
      competition: tournament.competition,
      showResults: true,
      placeholderLabels: GroupKnockoutPlan.createQualificationPlaceholders(
        context,
        tournament,
      ),
    );

    return Row(
      children: [
        for (Widget groupResult in groupResults) ...[
          groupResult,
          const SizedBox(width: bracket_sizes.groupKnockoutGroupGap),
        ],
        const SizedBox(width: bracket_sizes.groupKnockoutEliminationGap),
        eliminationTree,
      ],
    );
  }
}
