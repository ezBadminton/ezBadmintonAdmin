import 'dart:math';

import 'package:collection/collection.dart';
import 'package:ez_badminton_admin_app/utils/powers_of_two.dart';
import 'package:ez_badminton_admin_app/widgets/tournament_bracket_explorer/bracket_section.dart';
import 'package:ez_badminton_admin_app/widgets/tournament_brackets/consolation_elimination_tree.dart';
import 'package:ez_badminton_admin_app/widgets/tournament_brackets/double_elimination_tree.dart';
import 'package:ez_badminton_admin_app/widgets/tournament_brackets/round_robin_plan.dart';
import 'package:ez_badminton_admin_app/widgets/tournament_brackets/sectioned_bracket.dart';
import 'package:ez_badminton_admin_app/widgets/tournament_brackets/single_eliminiation_tree.dart';
import 'package:ez_badminton_admin_app/widgets/tournament_context/tournament_context.dart';
import 'package:flutter/material.dart';
import 'package:ez_badminton_admin_app/l10n/l10n.dart';
import 'package:model_repository/model_repository.dart';
import 'bracket_sizes.dart' as bracket_sizes;

class GroupKnockoutPlan extends StatelessWidget implements SectionedBracket {
  const GroupKnockoutPlan({
    super.key,
    required this.onDragAndDrop,
    required this.sections,
  });

  final void Function(Team a, Team b)? onDragAndDrop;

  @override
  final List<BracketSection> sections;

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;
    var tPlan = context.readTournamentPlan();
    var tournament = context.readTournament() as GroupKnockout;

    List<RoundRobin> groupRoundRobins = tournament.groupPhase.groups;

    List<Widget> groupPlans = groupRoundRobins
        .mapIndexed((index, group) => TournamentContextSubtree(
              tournamentGetter: (plan) =>
                  (plan.tournament as GroupKnockout).groupPhase.groups[index],
              child: RoundRobinPlan(
                onDragAndDrop: onDragAndDrop,
                title: l10n.groupNumber(index + 1),
              ),
            ))
        .toList();

    Map<Slot, Widget> placeholders =
        createQualificationPlaceholders(context, tournament, tPlan.competition);

    koPhaseGetter(TournamentPlan plan) =>
        (plan.tournament as GroupKnockout).knockoutPhase;

    Widget eliminationTree = switch (tournament.knockoutPhase) {
      SingleElimination e => TournamentContextSubtree(
          tournamentGetter: koPhaseGetter,
          child: SingleEliminationTree(
            rounds: e.rounds,
            placeholderLabels: placeholders,
            onDragAndDrop: onDragAndDrop,
          ),
        ),
      DoubleElimination e => TournamentContextSubtree(
          tournamentGetter: koPhaseGetter,
          child: DoubleEliminationTree(
            sections: DoubleEliminationTree.getSections(e),
            placeholderLabels: placeholders,
            onDragAndDrop: onDragAndDrop,
          ),
        ),
      SingleEliminationWithConsolation e => TournamentContextSubtree(
          tournamentGetter: koPhaseGetter,
          child: ConsolationEliminationTree(
            sections: SingleEliminationTree.getSections(e.mainBracket.rounds),
            placeholderLabels: placeholders,
            onDragAndDrop: onDragAndDrop,
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
    Competition competition,
  ) {
    var l10n = AppLocalizations.of(context)!;

    Map<Slot, String> labelTexts =
        createQualificationPlaceholderTexts(tournament, competition, l10n);

    Map<Slot, Widget> placeholders = labelTexts
        .map((participant, text) => MapEntry(participant, Text(text)));

    return placeholders;
  }

  static Map<Slot, String> createQualificationPlaceholderTexts(
    GroupKnockout tournament,
    Competition competition,
    AppLocalizations l10n,
  ) {
    var quals = orderGroupQualifications(competition, tournament.groupPhase);
    var firstKoRound = tournament.knockoutPhase.rounds.first;
    var firstKoSlots = firstKoRound
        .expand((m) => [m.slot1, m.slot2])
        .where((s) => !s.isBye)
        .toList();
    assert(quals.length == firstKoSlots.length);

    var placeholders = <Slot, String>{};
    for (final (i, qual) in quals.indexed) {
      var slot = firstKoSlots[i];
      String label;
      if (qual.isContested) {
        label = l10n.contestedGroupQualification(qual.place + 1);
      } else {
        label = l10n.groupQualification(qual.group + 1, qual.place + 1);
      }
      placeholders[slot] = label;
    }
    return placeholders;
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

class GroupQualification {
  GroupQualification(
    this.group,
    this.place, {
    this.isContested = false,
    this.isBye = false,
    this.inPool = true,
  });
  final int group;
  final int place;
  final bool isContested;
  final bool isBye;
  bool inPool;
}

List<GroupQualification> orderGroupQualifications(
  Competition competition,
  GroupPhase groupPhase,
) {
  int numQuals = (competition.tournamentModeSettings! as GroupKnockoutSettings)
      .numQualifications;
  int numGroups = groupPhase.groups.length;

  int numUncontested = numQuals ~/ numGroups;
  List<GroupQualification> qualifications = [];
  for (int place = 0; place < numUncontested; place += 1) {
    for (int group = 0; group < numGroups; group += 1) {
      qualifications.add(GroupQualification(group, place));
    }
  }

  int numContested = numQuals % numGroups;
  for (int i = 0; i < numContested; i += 1) {
    qualifications.add(GroupQualification(
      i,
      numUncontested,
      isContested: true,
    ));
  }

  int firstRoundSize = nextPowerOfTwo(qualifications.length);

  List<GroupQualification> pool = List.of(qualifications);
  pool.addAll(
    List.generate(
      firstRoundSize - qualifications.length,
      (_) => GroupQualification(-1, -1, isBye: true),
    ),
  );

  List<List<GroupQualification>> matchups = [pool];

  while (matchups[0].length != 2) {
    List<List<GroupQualification>> nextMatchups = [];
    for (final subPool in matchups) {
      final (upper, lower) = splitQualifications(subPool);
      nextMatchups.add(upper);
      nextMatchups.add(lower);
    }
    matchups = nextMatchups;
  }

  return matchups.flattened.where((qual) => !qual.isBye).toList();
}

(List<GroupQualification>, List<GroupQualification>) splitQualifications(
  List<GroupQualification> qualifications,
) {
  for (final qual in qualifications) {
    qual.inPool = true;
  }

  Map<GroupQualification, int> originalSeeds = {
    for (final (i, qual) in qualifications.indexed) qual: i,
  };

  int numQuals = qualifications.length;
  int numRounds = getNumRounds(numQuals);
  List<(int, int)> seedMatchups = arrangeSeeds(numRounds);

  List<(int, int)> upperSeedMatchups =
      seedMatchups.sublist(0, seedMatchups.length ~/ 2);
  List<(int, int)> lowerSeedMatchups =
      seedMatchups.sublist(seedMatchups.length ~/ 2);

  List<int> upperSeeds = List.filled(seedMatchups.length, -1);
  List<int> lowerSeeds = List.filled(seedMatchups.length, -1);

  for (final (i, matchup) in upperSeedMatchups.indexed) {
    upperSeeds[i] = matchup.$1;
    upperSeeds[seedMatchups.length - 1 - i] = matchup.$2;
  }
  for (final (i, matchup) in lowerSeedMatchups.indexed) {
    lowerSeeds[i] = matchup.$1;
    lowerSeeds[seedMatchups.length - 1 - i] = matchup.$2;
  }

  Map<int, int> upperGroups = {};
  Map<int, int> lowerGroups = {};

  List<GroupQualification> upper = [];
  List<GroupQualification> lower = [];

  for (final seed in upperSeeds) {
    final qualification =
        pickSeedWithGroupConstraint(qualifications, seed, upperGroups);
    int group = qualification.group;
    if (group >= 0) {
      final current = upperGroups[group] ?? 0;
      upperGroups[group] = current + 1;
    }
    upper.add(qualification);
  }

  for (final seed in lowerSeeds) {
    final qualification =
        pickSeedWithGroupConstraint(qualifications, seed, lowerGroups);
    int group = qualification.group;
    if (group >= 0) {
      final current = lowerGroups[group] ?? 0;
      lowerGroups[group] = current + 1;
    }
    lower.add(qualification);
  }

  upper.sortBy<num>((qual) => originalSeeds[qual]!);
  lower.sortBy<num>((qual) => originalSeeds[qual]!);

  return (upper, lower);
}

GroupQualification pickSeedWithGroupConstraint(
  List<GroupQualification> pool,
  int seed,
  Map<int, int> groupConstraint,
) {
  GroupQualification directCandidate = pool[seed];
  int constraint = groupConstraint[directCandidate.group] ?? 0;
  if (directCandidate.inPool && constraint == 0) {
    directCandidate.inPool = false;
    return directCandidate;
  }

  for (final alternativeCandidate in pool) {
    final inPool = alternativeCandidate.inPool;
    final samePlayer = alternativeCandidate.place == directCandidate.place;
    final noGroupConflict = groupConstraint[alternativeCandidate.group] == 0;
    if (inPool && samePlayer && noGroupConflict) {
      alternativeCandidate.inPool = false;
      return alternativeCandidate;
    }
  }

  List<GroupQualification> alternativeCandidates =
      pool.where((qual) => qual.inPool && !qual.isBye).toList();

  mergeSort(
    alternativeCandidates,
    compare: (a, b) {
      if (a == directCandidate) {
        return -1;
      }
      if (b == directCandidate) {
        return 1;
      }
      if (a.place == b.place) {
        return 0;
      }

      final aDistance = a.place - directCandidate.place;
      final bDistance = b.place - directCandidate.place;

      final aAbsDistance = aDistance.abs();
      final bAbsDistance = bDistance.abs();

      if (aAbsDistance == bAbsDistance) {
        if (aDistance > 0) {
          return -1;
        } else {
          return 1;
        }
      } else if (aAbsDistance < bAbsDistance) {
        return -1;
      } else {
        return 1;
      }
    },
  );

  mergeSort(
    alternativeCandidates,
    compare: (a, b) {
      final aConstraint = groupConstraint[a.group] ?? 0;
      final bConstraint = groupConstraint[b.group] ?? 0;
      return aConstraint.compareTo(bConstraint);
    },
  );

  alternativeCandidates[0].inPool = false;
  return alternativeCandidates[0];
}

int getNumRounds(int numSlots) {
  int rounds = 0;
  while (numSlots > 1) {
    numSlots >>= 1;
    rounds += 1;
  }
  return rounds;
}

List<(int, int)> arrangeSeeds(int rounds) {
  // The root node (the final) where the paths of seed 0 and 1 meet.
  List<(int, int)> seedMatchups = [(0, 1)];

  for (int r = 1; r < rounds; r += 1) {
    // Determine the matchups of the next 2^r seeds

    List<(int, int)> nextSeedMatchups = [];
    int totalSeeds = pow(2, r + 1) as int;
    for ((int, int) parentMatchup in seedMatchups) {
      int opponent1 = parentMatchup.$1;
      int opponent2 = parentMatchup.$2;

      nextSeedMatchups.add((opponent1, totalSeeds - 1 - opponent1));
      nextSeedMatchups.add((opponent2, totalSeeds - 1 - opponent2));
    }
    // Go up the tournament tree
    seedMatchups = nextSeedMatchups;
  }

  return seedMatchups;
}
