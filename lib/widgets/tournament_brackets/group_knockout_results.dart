import 'package:collection/collection.dart';
import 'package:ez_badminton_admin_app/widgets/tie_breaker_menu/tie_breaker_menu.dart';
import 'package:ez_badminton_admin_app/widgets/tournament_bracket_explorer/bracket_section.dart';
import 'package:ez_badminton_admin_app/widgets/tournament_brackets/consolation_elimination_tree.dart';
import 'package:ez_badminton_admin_app/widgets/tournament_brackets/double_elimination_tree.dart';
import 'package:ez_badminton_admin_app/widgets/tournament_brackets/group_knockout_plan.dart';
import 'package:ez_badminton_admin_app/widgets/tournament_brackets/round_robin_results.dart';
import 'package:ez_badminton_admin_app/widgets/tournament_brackets/sectioned_bracket.dart';
import 'package:ez_badminton_admin_app/widgets/tournament_brackets/single_eliminiation_tree.dart';
import 'package:ez_badminton_admin_app/widgets/tournament_context/tournament_context.dart';
import 'package:flutter/material.dart';
import 'package:ez_badminton_admin_app/l10n/l10n.dart';
import 'package:model_repository/model_repository.dart';
import 'bracket_sizes.dart' as bracket_sizes;

class GroupKnockoutResults extends StatelessWidget implements SectionedBracket {
  const GroupKnockoutResults({
    super.key,
    this.sections = const [],
  });

  @override
  final List<BracketSection> sections;

  @override
  bool get navigatable => true;

  @override
  Widget build(BuildContext context) {
    var tPlan = context.readTournamentPlan();
    var tournament = context.readTournament() as GroupKnockout;

    List<RoundRobin> groupRoundRobins = tournament.groupPhase.groups;

    List<Widget> groupResults = groupRoundRobins
        .mapIndexed(
          (i, g) => TournamentContextSubtree(
            tournamentGetter: (plan) =>
                (plan.tournament as GroupKnockout).groupPhase.groups[i],
            child: RoundRobinResults(),
          ),
        )
        .toList();

    Map<Slot, Widget> placeholders =
        GroupKnockoutPlan.createQualificationPlaceholders(
      context,
      tournament,
      tPlan.competition,
    );

    koPhaseGetter(TournamentPlan plan) =>
        (plan.tournament as GroupKnockout).knockoutPhase;

    Widget eliminationTree = switch (tournament.knockoutPhase) {
      SingleElimination e => TournamentContextSubtree(
          tournamentGetter: koPhaseGetter,
          child: SingleEliminationTree(
            rounds: e.rounds,
            showResults: true,
            placeholderLabels: placeholders,
          ),
        ),
      DoubleElimination e => TournamentContextSubtree(
          tournamentGetter: koPhaseGetter,
          child: DoubleEliminationTree(
            showResults: true,
            sections: DoubleEliminationTree.getSections(e),
            placeholderLabels: placeholders,
          ),
        ),
      SingleEliminationWithConsolation e => TournamentContextSubtree(
          tournamentGetter: koPhaseGetter,
          child: ConsolationEliminationTree(
            showResults: true,
            sections: SingleEliminationTree.getSections(e.mainBracket.rounds),
            placeholderLabels: placeholders,
          ),
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
        _CrossRankTieBreakerButtons(),
        knockoutResults,
      ],
    );
  }
}

class _CrossRankTieBreakerButtons extends StatelessWidget {
  const _CrossRankTieBreakerButtons();

  @override
  Widget build(BuildContext context) {
    var tPlan = context.readTournamentPlan();
    var tournament = context.readTournament() as GroupKnockout;

    if (!tournament.groupPhase.groupPhaseEnded || tournament.knockoutStarted) {
      // Do not allow editing of the tie breaker when knockout phase has started
      return const SizedBox();
    }

    List<List<Team>> unbrokenTeamTies =
        tournament.groupPhase.unbrokenCrossGroupTies;
    List<List<Team>> teamTies = tournament.groupPhase.crossGroupTies;

    if (unbrokenTeamTies.isEmpty) {
      return const SizedBox();
    }

    var l10n = AppLocalizations.of(context)!;
    int crossTiedRank = tournament.groupPhase.crossTiedRank;

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
                      competition: tPlan.competition,
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
