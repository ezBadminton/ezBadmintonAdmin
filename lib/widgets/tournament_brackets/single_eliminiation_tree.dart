import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/badminton_tournament_ops/badminton_match.dart';
import 'package:ez_badminton_admin_app/widgets/tournament_bracket_explorer/bracket_section.dart';
import 'package:ez_badminton_admin_app/widgets/tournament_bracket_explorer/bracket_section_subtree.dart';
import 'package:ez_badminton_admin_app/widgets/tournament_brackets/sectioned_bracket.dart';
import 'package:ez_badminton_admin_app/widgets/tournament_brackets/single_elimination_match_node.dart';
import 'package:flutter/material.dart';
import 'package:tournament_mode/tournament_mode.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SingleEliminationTree extends StatelessWidget
    implements SectionedBracket {
  SingleEliminationTree({
    super.key,
    required this.rounds,
    required this.competition,
    this.isEditable = false,
    this.placeholderLabels = const {},
  }) : _sections = _getSections(rounds);

  final List<EliminationRound<BadmintonMatch>> rounds;
  final Competition competition;

  final bool isEditable;

  final Map<MatchParticipant, String> placeholderLabels;

  final List<BracketSection> _sections;
  @override
  List<BracketSection> get sections => _sections;

  @override
  Widget build(BuildContext context) {
    List<Widget> roundNodes = [];

    for (EliminationRound<BadmintonMatch> round in rounds) {
      bool isFirst = rounds.first == round;
      bool isLast = rounds.last == round;

      roundNodes.add(
        BracketSectionSubtree(
          tournamentDataObject: round,
          child: Column(
            children: List.generate(
              round.matches.length,
              (index) => Expanded(
                child: SingleEliminationMatchNode(
                  match: round.matches[index],
                  teamSize: competition.teamSize,
                  matchIndex: index,
                  isFirstRound: isFirst,
                  isLastRound: isLast,
                  isEditable: isEditable,
                  placeholderLabels: placeholderLabels,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return IntrinsicHeight(
      child: Row(
        children: [
          for (Widget round in roundNodes) round,
        ],
      ),
    );
  }

  static List<BracketSection> _getSections(
      List<EliminationRound<BadmintonMatch>> rounds) {
    return rounds.map((round) {
      return BracketSection(
        tournamentDataObject: round,
        labelBuilder: (context) =>
            AppLocalizations.of(context)!.roundOfN('${round.roundSize}'),
      );
    }).toList();
  }
}
