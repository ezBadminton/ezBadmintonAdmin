import 'package:collection/collection.dart';
import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/badminton_tournament_ops/badminton_tournament_modes.dart';
import 'package:ez_badminton_admin_app/widgets/tournament_brackets/round_robin_plan.dart';
import 'package:ez_badminton_admin_app/widgets/tournament_brackets/single_eliminiation_tree.dart';
import 'package:flutter/material.dart';
import 'package:tournament_mode/tournament_mode.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class GroupKnockoutPlan extends StatelessWidget {
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
          const SizedBox(width: 30),
        ],
        const SizedBox(width: 50),
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
          finalGroupRanking[group * tournament.qualificationsPerGroup + place]:
              l10n.groupQualification(group + 1, place + 1),
    };

    return placeholders;
  }
}
