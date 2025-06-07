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
    required this.isEditable,
    required this.sections,
  });

  final bool isEditable;

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
                isEditable: isEditable,
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
          ),
        ),
      DoubleElimination e => TournamentContextSubtree(
          tournamentGetter: koPhaseGetter,
          child: DoubleEliminationTree(
            sections: DoubleEliminationTree.getSections(e),
            placeholderLabels: placeholders,
          ),
        ),
      SingleEliminationWithConsolation e => TournamentContextSubtree(
          tournamentGetter: koPhaseGetter,
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

class GroupQualification implements Comparable {
  GroupQualification(
    this.group,
    this.place, {
    this.isContested = false,
  });
  final int group;
  final int place;
  final bool isContested;

  @override
  int compareTo(other) {
    if (other is! GroupQualification) {
      throw ArgumentError("Other is not a GroupQualification");
    }
    int placeComparison = place.compareTo(other.place);
    if (placeComparison != 0) {
      return placeComparison;
    }

    int groupComparison = group.compareTo(other.group);
    return groupComparison;
  }

  int compareWithInvertedGroup(other) {
    if (other is! GroupQualification) {
      throw ArgumentError("Other is not a GroupQualification");
    }
    int placeComparison = place.compareTo(other.place);
    if (placeComparison != 0) {
      return placeComparison;
    }

    int groupComparison = -1 * group.compareTo(other.group);
    return groupComparison;
  }
}

class QualificationMatchup implements Comparable {
  QualificationMatchup(this.a, this.b);
  final GroupQualification a;
  final GroupQualification? b;

  GroupQualification getHigherPlaced() {
    if (b == null) {
      return a;
    }

    int comparison = a.compareTo(b);
    if (comparison == -1) {
      return a;
    } else {
      return b!;
    }
  }

  bool hasOverlappingGroups(QualificationMatchup? other) {
    if (other == null) {
      return false;
    }
    var groups = {a.group, if (b != null) b!.group};
    var otherGroups = {other.a.group, if (other.b != null) other.b!.group};
    return groups.intersection(otherGroups).isNotEmpty;
  }

  @override
  int compareTo(other) {
    if (other is! QualificationMatchup) {
      throw ArgumentError("Other is not a QualificationMatchup");
    }
    return getHigherPlaced().compareTo(other.getHigherPlaced());
  }

  int compareWithInvertedGroups(other) {
    if (other is! QualificationMatchup) {
      throw ArgumentError("Other is not a QualificationMatchup");
    }
    return getHigherPlaced().compareWithInvertedGroup(other.getHigherPlaced());
  }
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

  int firstRoundSize = previousPowerOfTwo(qualifications.length);
  int preRoundSize = qualifications.length - firstRoundSize;
  int numFirstRoundSlots = qualifications.length - 2 * preRoundSize;
  var firstQuals = qualifications.take(numFirstRoundSlots);
  var preQuals = qualifications.skip(numFirstRoundSlots).toList();

  var preMatchups = <QualificationMatchup>[];

  for (final qual in firstQuals) {
    preMatchups.add(QualificationMatchup(qual, null));
  }

  for (int i = 0; i < preRoundSize; i += 1) {
    var (a, b) = getPreRoundMatchup(preQuals);
    preMatchups.add(QualificationMatchup(a, b));
  }

  preMatchups.sort();

  var firstNamed = preMatchups.take(preMatchups.length ~/ 2);
  var pool = preMatchups.skip(preMatchups.length ~/ 2).toList();
  pool.sort((a, b) => a.compareWithInvertedGroups(b));

  var secondNamed = <QualificationMatchup>[];
  for (final first in firstNamed) {
    var second = getLowestMatchup(pool, first) ?? getLowestMatchup(pool, null)!;
    secondNamed.add(second);
  }

  var matchupOrder = <int>[0, 1];
  while (matchupOrder.length < firstRoundSize ~/ 2) {
    var nextLength = 2 * matchupOrder.length;
    for (final (i, orderI) in matchupOrder.indexed.toList()) {
      matchupOrder.replaceRange(
        2 * i,
        2 * i + 1,
        [orderI, nextLength - 1 - orderI],
      );
    }
  }

  var orderedMatchups = IterableZip([firstNamed, secondNamed]).toList();
  orderedMatchups = orderedMatchups
      .mapIndexed((i, _) => orderedMatchups[matchupOrder[i]])
      .toList();

  var orderedQuals = <GroupQualification>[];
  for (final matchup in orderedMatchups.flattened) {
    orderedQuals.add(matchup.a);
    if (matchup.b != null) {
      orderedQuals.add(matchup.b!);
    }
  }

  return orderedQuals;
}

(GroupQualification, GroupQualification) getPreRoundMatchup(
  List<GroupQualification> qualifications,
) {
  var highest = qualifications.removeAt(0);
  var lowest = getLowestQualification(qualifications, highest.group) ??
      getLowestQualification(qualifications, -1)!;

  return (highest, lowest);
}

GroupQualification? getLowestQualification(
  List<GroupQualification> qualifications,
  int groupConstraint,
) {
  GroupQualification? lowest;
  for (final qual in qualifications.reversed) {
    if (qual.group != groupConstraint) {
      lowest = qual;
      qualifications.remove(qual);
      break;
    }
  }
  return lowest;
}

QualificationMatchup? getLowestMatchup(
  List<QualificationMatchup> pool,
  QualificationMatchup? groupConstraint,
) {
  QualificationMatchup? lowest;
  for (final matchup in pool.reversed) {
    if (!matchup.hasOverlappingGroups(groupConstraint)) {
      lowest = matchup;
      pool.remove(matchup);
      break;
    }
  }
  return lowest;
}
