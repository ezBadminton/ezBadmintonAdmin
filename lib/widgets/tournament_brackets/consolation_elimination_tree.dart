import 'package:ez_badminton_admin_app/layout/elimination_tree/consolation_elimination_tree_layout.dart';
import 'package:ez_badminton_admin_app/widgets/tournament_bracket_explorer/bracket_section.dart';
import 'package:ez_badminton_admin_app/widgets/tournament_brackets/sectioned_bracket.dart';
import 'package:ez_badminton_admin_app/widgets/tournament_brackets/single_eliminiation_tree.dart';
import 'package:ez_badminton_admin_app/widgets/tournament_brackets/utils.dart';
import 'package:ez_badminton_admin_app/widgets/tournament_context/tournament_context.dart';
import 'package:flutter/material.dart';
import 'package:ez_badminton_admin_app/l10n/l10n.dart';
import 'package:model_repository/model_repository.dart';

class ConsolationEliminationTree extends StatelessWidget
    implements SectionedBracket {
  const ConsolationEliminationTree({
    super.key,
    this.onDragAndDrop,
    this.showResults = false,
    this.sections = const [],
    this.placeholderLabels = const {},
  });

  final void Function(Team a, Team b)? onDragAndDrop;
  final bool showResults;

  final Map<Slot, Widget> placeholderLabels;

  @override
  final List<BracketSection> sections;

  @override
  Widget build(BuildContext context) {
    var tPlan = context.readTournamentPlan();
    var tournament =
        context.readTournament() as SingleEliminationWithConsolation;

    ConsolationTreeNode consolationTreeRoot = _buildBracketTree(
      context,
      tournament.mainBracket,
      tPlan.competition,
      true,
    );

    return ConsolationEliminationTreeLayout(
      consolationTreeRoot: consolationTreeRoot,
    );
  }

  ConsolationTreeNode _buildBracketTree(
    BuildContext context,
    ConsolationBracket bracket,
    Competition competition,
    bool isMainBracket,
  ) {
    Map<Slot, Widget> placeholderLabels = Map.of(this.placeholderLabels)
      ..addAll(_createPlaceholderLabels(context, bracket));

    SingleEliminationTree tree = SingleEliminationTree(
      rounds: bracket.rounds,
      onDragAndDrop: isMainBracket ? onDragAndDrop : null,
      showResults: showResults,
      placeholderLabels: placeholderLabels,
    );

    List<ConsolationTreeNode> consolationTrees = bracket.consolations
        .map((consolationBracket) => _buildBracketTree(
              context,
              consolationBracket,
              competition,
              false,
            ))
        .toList();

    var matchNodeSize =
        SingleEliminationTree.getMatchNodeSize(competition.teamSize);
    var layoutSize =
        SingleEliminationTree.getLayoutSize(bracket.rounds, matchNodeSize);

    ConsolationTreeNode node = ConsolationTreeNode(
      bracket: bracket,
      treeWidget: tree,
      consolationBrackets: consolationTrees,
      matchNodeSize: matchNodeSize,
      layoutSize: layoutSize,
    );

    for (ConsolationTreeNode child in consolationTrees) {
      child.parent = node;
    }

    return node;
  }

  Map<Slot, Widget> _createPlaceholderLabels(
    BuildContext context,
    ConsolationBracket bracket,
  ) {
    if (bracket.isRoot) {
      return const {};
    }

    var l10n = AppLocalizations.of(context)!;

    Map<Slot, String> labelTexts =
        createConsolationPlaceholderLabels(l10n, bracket);

    Map<Slot, Widget> labels = wrapPlaceholderLabels(context, labelTexts);

    return labels;
  }

  static Map<Slot, String> createConsolationPlaceholderLabels(
    AppLocalizations l10n,
    ConsolationBracket bracket,
  ) {
    if (bracket.isRoot) {
      return const {};
    }

    List<TournamentMatch> firstRound = bracket.rounds.first;
    int bracketSize = firstRound.length * 2;
    String parentRoundName = l10n.roundOfN((bracketSize * 2).toString());
    Iterable<Slot> firstRoundSlots = firstRound.expand(
      (m) => [m.slot1, m.slot2],
    );

    Map<Slot, String> labels = {};
    for (final (i, slot) in firstRoundSlots.indexed) {
      if (slot.isBye) {
        continue;
      }
      String placeholder = l10n.loserOfMatch('$parentRoundName ${i + 1}');
      labels[slot] = placeholder;
    }

    return labels;
  }
}
