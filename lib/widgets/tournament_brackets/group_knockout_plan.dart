import 'package:collection/collection.dart';
import 'package:ez_badminton_admin_app/badminton_tournament_ops/badminton_tournament_modes.dart';
import 'package:ez_badminton_admin_app/widgets/tournament_bracket_explorer/bracket_section.dart';
import 'package:ez_badminton_admin_app/widgets/tournament_brackets/round_robin_plan.dart';
import 'package:ez_badminton_admin_app/widgets/tournament_brackets/sectioned_bracket.dart';
import 'package:ez_badminton_admin_app/widgets/tournament_brackets/single_eliminiation_tree.dart';
import 'package:flutter/material.dart';
import 'package:tournament_mode/tournament_mode.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'bracket_widths.dart' as bracket_widths;

class GroupKnockoutPlan extends StatelessWidget implements SectionedBracket {
  GroupKnockoutPlan({
    super.key,
    required this.tournament,
  }) : _sections = getSections(tournament);

  final BadmintonGroupKnockout tournament;

  final List<BracketSection> _sections;
  @override
  List<BracketSection> get sections => _sections;

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;

    List<BadmintonRoundRobin> groupRoundRobins =
        tournament.groupPhase.groupRoundRobins;

    List<RoundRobinPlan> groupPlans = groupRoundRobins
        .mapIndexed((index, group) => RoundRobinPlan(
              tournament: group,
              isEditable: true,
              title: l10n.groupNumber(index + 1),
            ))
        .toList();

    SingleEliminationTree eliminationTree = SingleEliminationTree(
      rounds: tournament.knockoutPhase.rounds,
      competition: tournament.competition,
      placeholderLabels: createQualificationPlaceholders(context, tournament),
    );

    return Row(
      children: [
        for (Widget groupPlan in groupPlans) ...[
          groupPlan,
          const SizedBox(width: bracket_widths.groupKnockoutGroupGap),
        ],
        const SizedBox(width: bracket_widths.groupKnockoutEliminationGap),
        eliminationTree,
      ],
    );
  }

  static Map<MatchParticipant, String> createQualificationPlaceholders(
    BuildContext context,
    BadmintonGroupKnockout tournament,
  ) {
    var l10n = AppLocalizations.of(context)!;
    List<MatchParticipant> finalGroupRanking =
        tournament.groupPhase.finalRanking.ranks;

    Map<MatchParticipant, String> placeholders = {
      for (int place = 0; place < tournament.qualificationsPerGroup; place += 1)
        for (int group = 0; group < tournament.numGroups; group += 1)
          finalGroupRanking[place * tournament.numGroups + group]:
              l10n.groupQualification(group + 1, place + 1),
    };

    return placeholders;
  }

  static List<BracketSection> getSections(
    BadmintonGroupKnockout tournament,
  ) {
    Iterable<BracketSection> groupSections =
        tournament.groupPhase.groupRoundRobins.mapIndexed(
      (index, group) => BracketSection(
        tournamentDataObjects: [group],
        labelBuilder: (context) =>
            AppLocalizations.of(context)!.groupNumber(index + 1),
      ),
    );

    Iterable<BracketSection> eliminationSections =
        tournament.knockoutPhase.rounds.map(
      (round) => BracketSection(
        tournamentDataObjects: round.matches,
        labelBuilder: (context) =>
            AppLocalizations.of(context)!.roundOfN('${round.roundSize}'),
      ),
    );

    return [...groupSections, ...eliminationSections];
  }
}
