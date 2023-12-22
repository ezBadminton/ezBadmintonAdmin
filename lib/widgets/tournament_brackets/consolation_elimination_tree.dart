import 'package:ez_badminton_admin_app/badminton_tournament_ops/badminton_tournament_modes.dart';
import 'package:ez_badminton_admin_app/layout/elimination_tree/consolation_elimination_tree_layout.dart';
import 'package:ez_badminton_admin_app/widgets/tournament_bracket_explorer/bracket_section.dart';
import 'package:ez_badminton_admin_app/widgets/tournament_brackets/sectioned_bracket.dart';
import 'package:ez_badminton_admin_app/widgets/tournament_brackets/single_eliminiation_tree.dart';
import 'package:flutter/material.dart';
import 'package:tournament_mode/tournament_mode.dart';

class ConsolationEliminationTree extends StatelessWidget
    implements SectionedBracket {
  ConsolationEliminationTree({
    super.key,
    required this.tournament,
    this.isEditable = false,
    this.showResults = false,
    this.placeholderLabels = const {},
  }) {
    consolationTreeRoot = _buildBracketTree(tournament.mainBracket);
  }

  final BadmintonSingleEliminationWithConsolation tournament;

  final bool isEditable;
  final bool showResults;

  final Map<MatchParticipant, Widget> placeholderLabels;

  late final ConsolationTreeNode consolationTreeRoot;

  @override
  List<BracketSection> get sections => consolationTreeRoot.mainBracket.sections;

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

    ConsolationTreeNode node = ConsolationTreeNode(
      mainBracket: tree,
      consolationBrackets: consolationTrees,
    );

    for (ConsolationTreeNode child in consolationTrees) {
      child.parent = node;
    }

    return node;
  }
}
