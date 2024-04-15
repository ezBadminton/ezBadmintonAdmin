import 'package:collection/collection.dart';
import 'package:ez_badminton_admin_app/badminton_tournament_ops/badminton_tournament_modes.dart';
import 'package:ez_badminton_admin_app/widgets/tournament_bracket_explorer/bracket_section.dart';
import 'package:ez_badminton_admin_app/widgets/tournament_brackets/consolation_elimination_tree.dart';
import 'package:ez_badminton_admin_app/widgets/tournament_brackets/double_elimination_tree.dart';
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

    Map<MatchParticipant<dynamic>, Widget> placeholders =
        createQualificationPlaceholders(context, tournament);

    Widget eliminationTree = switch (tournament.knockoutPhase) {
      BadmintonSingleElimination e => SingleEliminationTree(
          rounds: e.rounds,
          competition: tournament.competition,
          placeholderLabels: placeholders,
        ),
      BadmintonDoubleElimination e => DoubleEliminationTree(
          tournament: e,
          competition: tournament.competition,
          placeholderLabels: placeholders,
        ),
      BadmintonSingleEliminationWithConsolation e => ConsolationEliminationTree(
          tournament: e,
          placeholderLabels: placeholders,
        ),
      _ => throw Exception(
          "This elimination tournament does not have a tree widget implemented",
        ),
    };

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
      MatchParticipant knockoutSeedPlacement =
          (p.placement! as PassthroughPlacement).getUnblockedPlacement()!;
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
        switch (tournament.knockoutPhase) {
      BadmintonSingleElimination e =>
        SingleEliminationTree.getSections(e.rounds),
      BadmintonDoubleElimination e => DoubleEliminationTree.getSections(e),
      BadmintonSingleEliminationWithConsolation e =>
        SingleEliminationTree.getSections(e.mainBracket.bracket.rounds),
      _ => throw Exception(
          "No sections implemented for this elimination tournament",
        ),
    };

    return [...groupSections, ...eliminationSections];
  }
}
