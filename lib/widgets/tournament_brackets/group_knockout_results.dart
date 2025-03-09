import 'package:collection/collection.dart';
import 'package:ez_badminton_admin_app/widgets/tie_breaker_menu/tie_breaker_menu.dart';
import 'package:ez_badminton_admin_app/widgets/tournament_bracket_explorer/bracket_section.dart';
import 'package:ez_badminton_admin_app/widgets/tournament_brackets/consolation_elimination_tree.dart';
import 'package:ez_badminton_admin_app/widgets/tournament_brackets/double_elimination_tree.dart';
import 'package:ez_badminton_admin_app/widgets/tournament_brackets/group_knockout_plan.dart';
import 'package:ez_badminton_admin_app/widgets/tournament_brackets/round_robin_results.dart';
import 'package:ez_badminton_admin_app/widgets/tournament_brackets/sectioned_bracket.dart';
import 'package:ez_badminton_admin_app/widgets/tournament_brackets/single_eliminiation_tree.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:model_repository/model_repository.dart';
import 'bracket_sizes.dart' as bracket_sizes;

class GroupKnockoutResults extends StatelessWidget implements SectionedBracket {
  GroupKnockoutResults({
    super.key,
    required this.tPlan,
    required this.tournament,
  }) : sections = GroupKnockoutPlan.getSections(tournament);

  final TournamentPlan tPlan;
  final GroupKnockout tournament;

  @override
  final List<BracketSection> sections;

  @override
  Widget build(BuildContext context) {
    List<RoundRobin> groupRoundRobins = tournament.groupPhase.groups;

    List<Widget> groupResults = groupRoundRobins
        .map(
          (g) => RoundRobinResults(
            tPlan: tPlan,
            tournament: g,
            parentTournament: tournament,
          ),
        )
        .toList();

    Map<Slot, Widget> placeholders =
        GroupKnockoutPlan.createQualificationPlaceholders(context, tournament);

    Widget eliminationTree = switch (tournament.knockoutPhase) {
      SingleElimination e => SingleEliminationTree(
          tournament: e,
          competition: tPlan.competition,
          rounds: e.rounds,
          showResults: true,
          placeholderLabels: placeholders,
        ),
      DoubleElimination e => DoubleEliminationTree(
          tournament: e,
          competition: tPlan.competition,
          showResults: true,
          placeholderLabels: placeholders,
        ),
      SingleEliminationWithConsolation e => ConsolationEliminationTree(
          tournament: e,
          competition: tPlan.competition,
          showResults: true,
          placeholderLabels: placeholders,
        ),
      _ => throw Exception(
          "This elimination tournament does not have a tree widget implemented",
        ),
    };

    Widget knockoutResults = Row(
      children: [
        for (Widget groupResult in groupResults) ...[
          groupResult,
          const SizedBox(width: bracket_sizes.groupKnockoutGroupGap),
        ],
        const SizedBox(width: bracket_sizes.groupKnockoutEliminationGap),
        eliminationTree,
      ],
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _CrossRankTieBreakerButtons(
          tournament: tPlan,
        ),
        knockoutResults,
      ],
    );
  }
}

class _CrossRankTieBreakerButtons extends StatelessWidget {
  const _CrossRankTieBreakerButtons({
    required this.tournament,
  });

  final TournamentPlan tournament;
  GroupKnockout get groupKnockout => tournament.tournament as GroupKnockout;

  @override
  Widget build(BuildContext context) {
    if (groupKnockout.knockoutStarted) {
      // Do not allow editing of the tie breaker when knockout phase has started
      return const SizedBox();
    }

    List<List<Team>> unbrokenTeamTies =
        groupKnockout.groupPhase.unbrokenCrossGroupTies;
    List<List<Team>> teamTies = groupKnockout.groupPhase.crossGroupTies;

    if (unbrokenTeamTies.isEmpty) {
      return const SizedBox();
    }

    var l10n = AppLocalizations.of(context)!;
    int crossTiedRank = groupKnockout.groupPhase.crossTiedRank;

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 40),
      color: Theme.of(context).primaryColor.withOpacity(.25),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
          color: Theme.of(context).colorScheme.onSurface.withOpacity(.3),
          width: 2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: SizedBox(
          width: 470,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                l10n.crossGroupTies(unbrokenTeamTies.length),
                style: const TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 25),
              for (List<Team> tie in unbrokenTeamTies)
                SizedBox(
                  width: 290,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5.0),
                    child: TieBreakerButton(
                      competition: tournament.competition,
                      tie: tie,
                      tieRankLabel: l10n.nthPlace(crossTiedRank + 1),
                      buttonLabel: _isTieBroken(tie, teamTies)
                          ? l10n.editTieBreaker
                          : l10n.breakTie,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  bool _isTieBroken(List<Team> tie, List<List<Team>> allTies) {
    List<Team>? unbrokenTie = allTies.firstWhereOrNull(
      (t) => t.any((team) => tie.contains(team)),
    );

    return unbrokenTie == null;
  }
}
