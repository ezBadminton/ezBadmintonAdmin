import 'package:collection/collection.dart';
import 'package:ez_badminton_admin_app/badminton_tournament_ops/badminton_tournament_modes.dart';
import 'package:ez_badminton_admin_app/widgets/tournament_bracket_explorer/bracket_section.dart';
import 'package:ez_badminton_admin_app/widgets/tournament_brackets/round_robin_plan.dart';
import 'package:ez_badminton_admin_app/widgets/tournament_brackets/sectioned_bracket.dart';
import 'package:ez_badminton_admin_app/widgets/tournament_brackets/single_eliminiation_tree.dart';
import 'package:flutter/material.dart';
import 'package:tournament_mode/tournament_mode.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'bracket_sizes.dart' as bracket_sizes;

class GroupKnockoutPlan extends StatelessWidget implements SectionedBracket {
  GroupKnockoutPlan({
    super.key,
    required this.tournament,
    required this.isEditable,
  }) : _sections = getSections(tournament);

  final BadmintonGroupKnockout tournament;

  final bool isEditable;

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
              isEditable: isEditable,
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
          const SizedBox(width: bracket_sizes.groupKnockoutGroupGap),
        ],
        const SizedBox(width: bracket_sizes.groupKnockoutEliminationGap),
        eliminationTree,
      ],
    );
  }

  static Map<MatchParticipant, Widget> createQualificationPlaceholders(
    BuildContext context,
    BadmintonGroupKnockout tournament,
  ) {
    var l10n = AppLocalizations.of(context)!;
    List<MatchParticipant> knockoutEntries = tournament
        .knockoutPhase.entries.ranks
        .where((p) => p.placement != null)
        .toList();

    Map<MatchParticipant, Widget> placeholders = {};

    for (MatchParticipant p in knockoutEntries) {
      MatchParticipant knockoutSeedPlacement = p.placement!.getPlacement()!;
      MatchParticipant qualificationPlacement =
          knockoutSeedPlacement.placement!.getPlacement()!;

      GroupPhasePlacement groupPlacement =
          qualificationPlacement.placement! as GroupPhasePlacement;

      String groupPlaceholder =
          groupPlacement.isCrossGroup ? '?' : '${groupPlacement.group + 1}';

      placeholders[p] = Text(
        l10n.groupQualification(groupPlaceholder, groupPlacement.place + 1),
      );
    }

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
