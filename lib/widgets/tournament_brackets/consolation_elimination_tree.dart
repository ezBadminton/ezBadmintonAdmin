import 'package:ez_badminton_admin_app/layout/elimination_tree/consolation_elimination_tree_layout.dart';
import 'package:ez_badminton_admin_app/widgets/tournament_bracket_explorer/bracket_section.dart';
import 'package:ez_badminton_admin_app/widgets/tournament_brackets/sectioned_bracket.dart';
import 'package:ez_badminton_admin_app/widgets/tournament_brackets/single_eliminiation_tree.dart';
import 'package:ez_badminton_admin_app/widgets/tournament_context/tournament_context.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:model_repository/model_repository.dart';

class ConsolationEliminationTree extends StatelessWidget
    implements SectionedBracket {
  const ConsolationEliminationTree({
    super.key,
    this.isEditable = false,
    this.showResults = false,
    this.sections = const [],
    this.placeholderLabels = const {},
  });

  final bool isEditable;
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
    );

    return ConsolationEliminationTreeLayout(
      consolationTreeRoot: consolationTreeRoot,
    );
  }

  ConsolationTreeNode _buildBracketTree(
    BuildContext context,
    ConsolationBracket bracket,
    Competition competition,
  ) {
    Map<Slot, Widget> placeholderLabels = Map.of(this.placeholderLabels)
      ..addAll(_createPlaceholderLabels(context, bracket));

    SingleEliminationTree tree = SingleEliminationTree(
      rounds: bracket.rounds,
      isEditable: isEditable,
      showResults: showResults,
      placeholderLabels: placeholderLabels,
    );

    List<ConsolationTreeNode> consolationTrees = bracket.consolations
        .map((consolationBracket) => _buildBracketTree(
              context,
              consolationBracket,
              competition,
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
    return <Slot, Widget>{};
    // TODO
    /*
    if (bracket.parent == null) {
      return const {};
    }

    var l10n = AppLocalizations.of(context)!;

    Map<MatchParticipant, String> labelTexts =
        createConsolationPlaceholderLabels(l10n, bracket);

    Map<MatchParticipant, Widget> labels =
        wrapPlaceholderLabels(context, labelTexts);

    return labels;
    */
  }

  static Map<Slot, String> createConsolationPlaceholderLabels(
    AppLocalizations l10n,
    ConsolationBracket bracket,
  ) {
    return <Slot, String>{};
    // TODO
    /*
    if (bracket.parent == null) {
      return const {};
    }

    List<TournamentMatch> firstRoundMatches =
        bracket.bracket.rounds.first.matches;

    Map<MatchParticipant, String> labels = Map.fromEntries(
      firstRoundMatches
          .expand((match) => [match.a, match.b])
          .where((participant) => !participant.isBye)
          .map((participant) {
        WinnerRanking winnerRanking =
            participant.placement!.ranking as WinnerRanking;
        TournamentMatch sourceMatch = winnerRanking.match;

        String matchName = (sourceMatch.round as EliminationRound)
            .getSingleEliminationMatchName(l10n, sourceMatch);

        String loserLabel = l10n.loserOfMatch(matchName);

        return MapEntry(participant, loserLabel);
      }),
    );

    return labels;
  */
  }
}
