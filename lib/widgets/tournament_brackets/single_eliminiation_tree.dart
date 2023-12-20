import 'package:collection/collection.dart';
import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/badminton_tournament_ops/badminton_match.dart';
import 'package:ez_badminton_admin_app/layout/elimination_tree/elimination_tree_layout.dart';
import 'package:ez_badminton_admin_app/widgets/match_label/match_label.dart';
import 'package:ez_badminton_admin_app/widgets/tournament_bracket_explorer/bracket_section.dart';
import 'package:ez_badminton_admin_app/widgets/tournament_brackets/sectioned_bracket.dart';
import 'package:flutter/material.dart';
import 'package:tournament_mode/tournament_mode.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'bracket_sizes.dart' as bracket_sizes;

class SingleEliminationTree extends StatelessWidget
    implements SectionedBracket {
  SingleEliminationTree({
    super.key,
    required this.rounds,
    required this.competition,
    this.isEditable = false,
    this.showResults = false,
    this.placeholderLabels = const {},
  }) : _sections = getSections(rounds) {
    matchNodeSize = getMatchNodeSize(competition.teamSize);
    layoutSize = _getLayoutSize();
  }

  final List<EliminationRound<BadmintonMatch>> rounds;
  final Competition competition;

  final bool isEditable;
  final bool showResults;

  final Map<MatchParticipant, Widget> placeholderLabels;

  late final Size matchNodeSize;
  late final Size layoutSize;

  final List<BracketSection> _sections;
  @override
  List<BracketSection> get sections => _sections;

  @override
  Widget build(BuildContext context) {
    List<List<Widget>> matchNodes = [];

    for ((int, EliminationRound<BadmintonMatch>) roundEntry in rounds.indexed) {
      int roundIndex = roundEntry.$1;
      EliminationRound<BadmintonMatch> round = roundEntry.$2;

      List<Widget> roundMatchNodes =
          round.matches.mapIndexed((matchIndex, match) {
        Widget matchCard = MatchupCard(
          match: match,
          isEditable: isEditable && roundIndex == 0,
          placeholderLabels: placeholderLabels,
          showResult: showResults,
          width: matchNodeSize.width,
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

  Size _getLayoutSize() {
    int numRounds = rounds.length;
    int firstRoundLength = rounds.first.length;

    return Size(
      numRounds * matchNodeSize.width +
          (numRounds - 1) * bracket_sizes.singleEliminationRoundGap,
      firstRoundLength * matchNodeSize.height,
    );
  }

  static List<BracketSection> getSections(
    List<EliminationRound<BadmintonMatch>> rounds,
  ) {
    return rounds.map((round) {
      return BracketSection(
        tournamentDataObjects: round.matches,
        labelBuilder: (context) =>
            AppLocalizations.of(context)!.roundOfN('${round.roundSize}'),
      );
    }).toList();
  }
}
