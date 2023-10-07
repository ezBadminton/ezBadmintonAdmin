import 'package:collection/collection.dart';
import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/badminton_tournament_ops/badminton_tournament_modes.dart';
import 'package:ez_badminton_admin_app/widgets/tournament_brackets/round_robin_plan.dart';
import 'package:ez_badminton_admin_app/widgets/tournament_brackets/section_labels.dart';
import 'package:ez_badminton_admin_app/widgets/tournament_brackets/single_eliminiation_tree.dart';
import 'package:flutter/material.dart';
import 'package:tournament_mode/tournament_mode.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'bracket_widths.dart' as bracket_widths;

class GroupKnockoutPlan extends StatelessWidget implements SectionLabels {
  const GroupKnockoutPlan({
    super.key,
    required this.tournament,
    required this.competition,
  });

  final BadmintonGroupKnockout tournament;
  final Competition competition;

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;

    List<RoundRobin<Team, List<MatchSet>>> groupRoundRobins =
        tournament.groupPhase.groupRoundRobins;

    List<RoundRobinPlan> groupPlans = groupRoundRobins
        .mapIndexed((index, group) => RoundRobinPlan(
              tournament: group,
              competition: competition,
              isEditable: true,
              title: l10n.groupNumber(index + 1),
            ))
        .toList();

    SingleEliminationTree eliminationTree = SingleEliminationTree(
      rounds: tournament.knockoutPhase.rounds,
      competition: competition,
      placeholderLabels: _createQualificationPlaceholders(context),
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

  Map<MatchParticipant, String> _createQualificationPlaceholders(
    BuildContext context,
  ) {
    var l10n = AppLocalizations.of(context)!;
    List<MatchParticipant> finalGroupRanking =
        tournament.groupPhase.finalRanking.rank();

    Map<MatchParticipant, String> placeholders = {
      for (int place = 0; place < tournament.qualificationsPerGroup; place += 1)
        for (int group = 0; group < tournament.numGroups; group += 1)
          finalGroupRanking[place * tournament.numGroups + group]:
              l10n.groupQualification(group + 1, place + 1),
    };

    return placeholders;
  }

  @override
  List<SectionLabel> getSectionLabels(AppLocalizations l10n) {
    int numGroups = tournament.numGroups;

    List<SectionLabel> groupPhaseSectionLabels = [
      for (int g = 0; g < numGroups; g += 1) ...[
        SectionLabel(
          width: bracket_widths.roundRobinTableWidth,
          label: l10n.groupNumber(g + 1),
        ),
        SectionLabel(width: bracket_widths.groupKnockoutGroupGap),
      ],
    ];

    SingleEliminationTree eliminationTree = SingleEliminationTree(
      rounds: tournament.knockoutPhase.rounds,
      competition: competition,
    );

    List<SectionLabel> eliminationSectionLabels =
        eliminationTree.getSectionLabels(l10n);

    return [
      ...groupPhaseSectionLabels,
      SectionLabel(width: bracket_widths.groupKnockoutEliminationGap),
      ...eliminationSectionLabels,
    ];
  }
}
