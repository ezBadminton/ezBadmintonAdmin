import 'package:ez_badminton_admin_app/badminton_tournament_ops/badminton_tournament_modes.dart';
import 'package:ez_badminton_admin_app/layout/elimination_tree/consolation_elimination_tree_layout.dart';
import 'package:ez_badminton_admin_app/widgets/tournament_brackets/single_eliminiation_tree.dart';
import 'package:flutter/material.dart';
import 'package:tournament_mode/tournament_mode.dart';

class ConsolationEliminationTree extends StatelessWidget {
  const ConsolationEliminationTree({
    super.key,
    required this.tournament,
    this.isEditable = false,
    this.showResults = false,
    this.placeholderLabels = const {},
  });

  final BadmintonSingleEliminationWithConsolation tournament;

  final bool isEditable;
  final bool showResults;

  final Map<MatchParticipant, Widget> placeholderLabels;

  @override
  Widget build(BuildContext context) {
    ConsolationTreeNode consolationTreeRoot =
        _buildBracketTree(tournament.mainBracket);

    return ConsolationEliminationTreeLayout(
      consolationTreeRoot: consolationTreeRoot,
    );
  }

  ConsolationTreeNode _buildBracketTree(BracketWithConsolation bracket) {
    SingleEliminationTree tree = SingleEliminationTree(
      rounds: bracket.bracket.rounds.cast(),
      competition: (bracket.bracket as BadmintonSingleElimination).competition,
      isEditable: isEditable,
      showResults: showResults,
      placeholderLabels: placeholderLabels,
    );

    List<ConsolationTreeNode> consolationTrees = bracket.consolationBrackets
        .map((consolationBracket) => _buildBracketTree(consolationBracket))
        .toList();

    return ConsolationTreeNode(
      mainBracket: tree,
      consolationBrackets: consolationTrees,
    );
  }
}
