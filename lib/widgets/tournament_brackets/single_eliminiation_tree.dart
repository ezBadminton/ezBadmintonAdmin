import 'package:collection/collection.dart';
import 'package:ez_badminton_admin_app/layout/elimination_tree/elimination_tree_layout.dart';
import 'package:ez_badminton_admin_app/widgets/match_label/match_label.dart';
import 'package:ez_badminton_admin_app/widgets/tournament_bracket_explorer/bracket_section.dart';
import 'package:ez_badminton_admin_app/widgets/tournament_brackets/sectioned_bracket.dart';
import 'package:ez_badminton_admin_app/widgets/tournament_context/tournament_context.dart';
import 'package:flutter/material.dart';
import 'package:model_repository/model_repository.dart';
import 'package:ez_badminton_admin_app/l10n/l10n.dart';
import 'bracket_sizes.dart' as bracket_sizes;

class SingleEliminationTree extends StatelessWidget
    implements SectionedBracket {
  SingleEliminationTree({
    super.key,
    required this.rounds,
    this.isEditable = false,
    this.showResults = false,
    this.placeholderLabels = const {},
  }) : _sections = getSections(rounds);

  final List<List<TournamentMatch>> rounds;

  final bool isEditable;
  final bool showResults;

  final Map<Slot, Widget> placeholderLabels;

  final List<BracketSection> _sections;
  @override
  List<BracketSection> get sections => _sections;

  @override
  bool get navigatable => true;

  @override
  Widget build(BuildContext context) {
    var tPlan = context.readTournamentPlan();
    var competition = tPlan.competition;

    var matchNodeSize = getMatchNodeSize(competition.teamSize);
    var layoutSize = getLayoutSize(rounds, matchNodeSize);
    List<List<Widget>> matchNodes = [];

    for ((int, List<TournamentMatch>) roundEntry in rounds.indexed) {
      int roundIndex = roundEntry.$1;
      List<TournamentMatch> round = roundEntry.$2;

      List<Widget> roundMatchNodes = round.mapIndexed((matchIndex, match) {
        Widget matchCard = MatchContextSubtree(
          key: ValueKey('SingleEliminationMatch-${match.id}'),
          match: match,
          child: MatchupCard(
            isEditable: isEditable && roundIndex == 0,
            placeholderLabels: placeholderLabels,
            showResult: showResults,
            width: matchNodeSize.width,
          ),
        );

        return matchCard;
      }).toList();

      matchNodes.add(roundMatchNodes);
    }

    return EliminationTreeLayout(
      matchNodes: matchNodes,
      matchNodeSize: matchNodeSize,
      layoutSize: layoutSize,
      roundGapWidth: bracket_sizes.singleEliminationRoundGap,
    );
  }

  static Size getMatchNodeSize(int teamSize) {
    return Size(
      bracket_sizes.singleEliminationNodeWidth,
      teamSize == 1
          ? bracket_sizes.singlesMatchCardHeight
          : bracket_sizes.doublesMatchCardHeight,
    );
  }

  static Size getLayoutSize(
    List<List<TournamentMatch>> rounds,
    Size matchNodeSize,
  ) {
    int numRounds = rounds.length;
    int firstRoundLength = rounds.first.length;

    return Size(
      numRounds * matchNodeSize.width +
          (numRounds - 1) * bracket_sizes.singleEliminationRoundGap,
      firstRoundLength * matchNodeSize.height,
    );
  }

  static List<BracketSection> getSections(
    List<List<TournamentMatch>> rounds,
  ) {
    return rounds.map((round) {
      return BracketSection(
        tournamentDataObjects: round,
        labelBuilder: (context) =>
            AppLocalizations.of(context)!.roundOfN('${round.length * 2}'),
      );
    }).toList();
  }
}
