import 'package:ez_badminton_admin_app/badminton_tournament_ops/badminton_tournament_modes.dart';
import 'package:ez_badminton_admin_app/display_strings/match_names.dart';
import 'package:ez_badminton_admin_app/layout/elimination_tree/consolation_elimination_tree_layout.dart';
import 'package:ez_badminton_admin_app/widgets/tournament_bracket_explorer/bracket_section.dart';
import 'package:ez_badminton_admin_app/widgets/tournament_brackets/sectioned_bracket.dart';
import 'package:ez_badminton_admin_app/widgets/tournament_brackets/single_eliminiation_tree.dart';
import 'package:ez_badminton_admin_app/widgets/tournament_brackets/utils.dart';
import 'package:flutter/material.dart';
import 'package:tournament_mode/tournament_mode.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ConsolationEliminationTree extends StatelessWidget
    implements SectionedBracket {
  ConsolationEliminationTree({
    super.key,
    required this.tournament,
    this.isEditable = false,
    this.showResults = false,
    this.placeholderLabels = const {},
  }) : sections = SingleEliminationTree.getSections(
          tournament.mainBracket.bracket.rounds,
        );

  final BadmintonSingleEliminationWithConsolation tournament;

  final bool isEditable;
  final bool showResults;

  final Map<MatchParticipant, Widget> placeholderLabels;

  @override
  final List<BracketSection> sections;

  @override
  Widget build(BuildContext context) {
    ConsolationTreeNode consolationTreeRoot =
        _buildBracketTree(context, tournament.mainBracket);

    return ConsolationEliminationTreeLayout(
      consolationTreeRoot: consolationTreeRoot,
    );
  }

  ConsolationTreeNode _buildBracketTree(
    BuildContext context,
    BracketWithConsolation bracket,
  ) {
    Map<MatchParticipant, Widget> placeholderLabels =
        Map.of(this.placeholderLabels)
          ..addAll(_createPlaceholderLabels(context, bracket));

    SingleEliminationTree tree = SingleEliminationTree(
      rounds: bracket.bracket.rounds.cast(),
      competition: (bracket.bracket as BadmintonSingleElimination).competition,
      isEditable: isEditable,
      showResults: showResults,
      placeholderLabels: placeholderLabels,
    );

    List<ConsolationTreeNode> consolationTrees = bracket.consolationBrackets
        .map((consolationBracket) => _buildBracketTree(
              context,
              consolationBracket,
            ))
        .toList();

    ConsolationTreeNode node = ConsolationTreeNode(
      bracket: bracket,
      treeWidget: tree,
      consolationBrackets: consolationTrees,
    );

    for (ConsolationTreeNode child in consolationTrees) {
      child.parent = node;
    }

    return node;
  }

  Map<MatchParticipant, Widget> _createPlaceholderLabels(
    BuildContext context,
    BracketWithConsolation bracket,
  ) {
    if (bracket.parent == null) {
      return const {};
    }

    var l10n = AppLocalizations.of(context)!;

    Map<MatchParticipant, String> labelTexts =
        createConsolationPlaceholderLabels(l10n, bracket);

    Map<MatchParticipant, Widget> labels =
        wrapPlaceholderLabels(context, labelTexts);

    return labels;
  }

  static Map<MatchParticipant, String> createConsolationPlaceholderLabels(
    AppLocalizations l10n,
    BracketWithConsolation bracket,
  ) {
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
  }
}
