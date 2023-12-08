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
import 'bracket_widths.dart' as bracket_widths;

class SingleEliminationTree extends StatelessWidget
    implements SectionedBracket {
  SingleEliminationTree({
    super.key,
    required this.rounds,
    required this.competition,
    this.isEditable = false,
    this.showResults = false,
    this.placeholderLabels = const {},
  }) : _sections = _getSections(rounds);

  final List<EliminationRound<BadmintonMatch>> rounds;
  final Competition competition;

  final bool isEditable;
  final bool showResults;

  final Map<MatchParticipant, String> placeholderLabels;

  final List<BracketSection> _sections;
  @override
  List<BracketSection> get sections => _sections;

  @override
  Widget build(BuildContext context) {
    List<List<Widget>> matchNodes = [];

    Size matchNodeSize = Size(
      bracket_widths.singleEliminationNodeWith,
      competition.teamSize == 1 ? 80 : 118,
    );

    for (EliminationRound<BadmintonMatch> round in rounds) {
      List<Widget> roundMatchNodes =
          round.matches.mapIndexed((matchIndex, match) {
        Widget matchCard = MatchupCard(
          match: match,
          isEditable: isEditable,
          placeholderLabels: placeholderLabels,
          showResult: true,
          width: matchNodeSize.width,
        );

        return matchCard;
      }).toList();

      matchNodes.add(roundMatchNodes);
    }

    return EliminationTreeLayout(
      matchNodes: matchNodes,
      matchNodeSize: matchNodeSize,
      roundGapWidth: bracket_widths.singleEliminationRoundGap,
    );
  }

  static List<BracketSection> _getSections(
      List<EliminationRound<BadmintonMatch>> rounds) {
    return rounds.map((round) {
      return BracketSection(
        tournamentDataObjects: round.matches,
        labelBuilder: (context) =>
            AppLocalizations.of(context)!.roundOfN('${round.roundSize}'),
      );
    }).toList();
  }
}
