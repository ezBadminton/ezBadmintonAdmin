import 'package:collection/collection.dart';
import 'package:ez_badminton_admin_app/widgets/tournament_bracket_explorer/bracket_section.dart';
import 'package:ez_badminton_admin_app/widgets/tournament_brackets/consolation_elimination_tree.dart';
import 'package:ez_badminton_admin_app/widgets/tournament_brackets/double_elimination_tree.dart';
import 'package:ez_badminton_admin_app/widgets/tournament_brackets/round_robin_plan.dart';
import 'package:ez_badminton_admin_app/widgets/tournament_brackets/sectioned_bracket.dart';
import 'package:ez_badminton_admin_app/widgets/tournament_brackets/single_eliminiation_tree.dart';
import 'package:ez_badminton_admin_app/widgets/tournament_context/tournament_context.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:model_repository/model_repository.dart';
import 'bracket_sizes.dart' as bracket_sizes;

class GroupKnockoutPlan extends StatelessWidget implements SectionedBracket {
  const GroupKnockoutPlan({
    super.key,
    required this.isEditable,
    required this.sections,
  });

  final bool isEditable;

  @override
  final List<BracketSection> sections;

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;
    var tContext =
        context.read<TournamentContext>() as TournamentContext<GroupKnockout>;
    var tournament = tContext.tournament;

    List<RoundRobin> groupRoundRobins = tournament.groupPhase.groups;

    List<Widget> groupPlans = groupRoundRobins
        .mapIndexed((index, group) => TournamentContextSubtree(
              tContext.copyWith(group),
              child: RoundRobinPlan(
                isEditable: isEditable,
                title: l10n.groupNumber(index + 1),
              ),
            ))
        .toList();

    Map<Slot, Widget> placeholders =
        createQualificationPlaceholders(context, tournament);

    Widget eliminationTree = switch (tournament.knockoutPhase) {
      SingleElimination e => TournamentContextSubtree(
          tContext.copyWith(e),
          child: SingleEliminationTree(
            rounds: e.rounds,
            placeholderLabels: placeholders,
          ),
        ),
      DoubleElimination e => TournamentContextSubtree(
          tContext.copyWith(e),
          child: DoubleEliminationTree(
            sections: DoubleEliminationTree.getSections(e),
            placeholderLabels: placeholders,
          ),
        ),
      SingleEliminationWithConsolation e => TournamentContextSubtree(
          tContext.copyWith(e),
          child: ConsolationEliminationTree(
            sections: SingleEliminationTree.getSections(e.mainBracket.rounds),
            placeholderLabels: placeholders,
          ),
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

  static Map<Slot, Widget> createQualificationPlaceholders(
    BuildContext context,
    GroupKnockout tournament,
  ) {
    var l10n = AppLocalizations.of(context)!;

    Map<Slot, String> labelTexts =
        createQualificationPlaceholderTexts(tournament, l10n);

    Map<Slot, Widget> placeholders = labelTexts
        .map((participant, text) => MapEntry(participant, Text(text)));

    return placeholders;
  }

  static Map<Slot, String> createQualificationPlaceholderTexts(
    GroupKnockout tournament,
    AppLocalizations l10n,
  ) {
    // TODO
    return <Slot, String>{};
    /*
    List<Slot> knockoutEntries = tournament.knockoutPhase.entries.ranks
        .where((p) => p.placement != null)
        .toList();

    Map<Slot, String> placeholders = {};

    for (Team p in knockoutEntries) {
      MatchParticipant knockoutSeedPlacement =
          (p.placement! as PassthroughPlacement).getUnblockedPlacement()!;
      MatchParticipant qualificationPlacement =
          knockoutSeedPlacement.placement!.getPlacement()!;

      GroupPhasePlacement groupPlacement =
          qualificationPlacement.placement! as GroupPhasePlacement;

      String groupPlaceholder =
          groupPlacement.isCrossGroup ? '?' : '${groupPlacement.group + 1}';

      placeholders[p] =
          l10n.groupQualification(groupPlaceholder, groupPlacement.place + 1);
    }

    return placeholders;
    */
  }

  static List<BracketSection> getSections(
    GroupKnockout tournament,
  ) {
    Iterable<BracketSection> groupSections =
        tournament.groupPhase.groups.mapIndexed(
      (index, group) => BracketSection(
        tournamentDataObjects: [group],
        labelBuilder: (context) =>
            AppLocalizations.of(context)!.groupNumber(index + 1),
      ),
    );

    Iterable<BracketSection> eliminationSections =
        switch (tournament.knockoutPhase) {
      SingleElimination e => SingleEliminationTree.getSections(e.rounds),
      DoubleElimination e => DoubleEliminationTree.getSections(e),
      SingleEliminationWithConsolation e =>
        SingleEliminationTree.getSections(e.mainBracket.rounds),
      _ => throw Exception(
          "No sections implemented for this elimination tournament",
        ),
    };

    return [...groupSections, ...eliminationSections];
  }
}
