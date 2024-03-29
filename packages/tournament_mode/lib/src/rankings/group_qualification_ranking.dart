import 'dart:math';

import 'package:collection/collection.dart';
import 'package:tournament_mode/src/match_participant.dart';
import 'package:tournament_mode/src/modes/group_knockout.dart';
import 'package:tournament_mode/src/modes/group_phase.dart';
import 'package:tournament_mode/src/modes/single_elimination.dart';
import 'package:tournament_mode/src/ranking.dart';
import 'package:tournament_mode/src/rankings/group_phase_ranking.dart';
import 'package:tournament_mode/src/rankings/ranking_decorator.dart';

/// A ranking that converts the final [GroupPhaseRanking] from a [GroupPhase]
/// into seeds for a [SingleElimination].
///
/// The seeds are arranged such that in the first round the top placed group
/// members play lower placed ones and the group members don't meet too early
/// in the knockouts.
///
/// See also:
///  * [GroupKnockout] where this ranking is used as a transition between
/// group phase and knockout phase.
class GroupQualificationRanking<P> extends RankingDecorator<P> {
  /// Creates a [GroupQualificationRanking] from the [targetRanking] which is
  /// a [GroupPhaseRanking].
  ///
  /// The [numGroups] and [qualificationsPerGroup] under which the
  /// [targetRanking] was played out need to be provided.
  GroupQualificationRanking(
    GroupPhaseRanking<P, dynamic, dynamic> targetRanking, {
    required this.numGroups,
    required this.numQualifications,
  }) : super(targetRanking);

  @override
  GroupPhaseRanking<P, dynamic, dynamic> get targetRanking =>
      super.targetRanking as GroupPhaseRanking<P, dynamic, dynamic>;

  final int numGroups;
  final int numQualifications;

  @override
  List<MatchParticipant<P>> createRanks() {
    List<int> groupKnockoutSeeds = _createGroupKnockoutSeeds();

    List<MatchParticipant<P>> seeds = List.generate(
      numQualifications,
      (index) {
        int rank = groupKnockoutSeeds[index];
        return MatchParticipant.fromPlacement(
          Placement(ranking: targetRanking, place: rank),
        );
      },
    );

    return seeds;
  }

  List<int> _createGroupKnockoutSeeds() {
    List<_GroupQualification> qualifications = _createGroupQualifications();

    int baseNumQualified = _getPreviousPowerOfTwo(numQualifications);

    // If the number of qualified participants is not a power of two, extra KO
    // matches need to be played before the first fully filled elimination
    // round can take place.
    int extraKOs = numQualifications - baseNumQualified;

    // The list of qualifications who don't need to play and extra KO.
    // Or - if no extra KOs are needed - it's just the full qualifications list.
    List<_GroupQualification> directQualifications = qualifications.sublist(
      0,
      numQualifications - extraKOs * 2,
    );
    // List of qualifications who have to play one extra KO round
    List<_GroupQualification> extraKOPool = qualifications.sublist(
      numQualifications - extraKOs * 2,
    );

    // The list of extra KO matchups. If none are needed this is just a list
    // of byes.
    List<_GroupKnockoutMatchup> preRoundMatchups = directQualifications
        .map((q) => _GroupKnockoutMatchup(q, null))
        .toList();

    // Create the extra KO matchups (if any)
    for (int i = 0; i < extraKOs; i += 1) {
      // Match highest available place vs the lowest
      _GroupQualification a = extraKOPool.first;
      // Avoid group rematches
      _GroupQualification b =
          extraKOPool.where((q) => q.group != a.group).lastOrNull ??
              extraKOPool.last;

      extraKOPool.remove(a);
      extraKOPool.remove(b);

      preRoundMatchups.add(_GroupKnockoutMatchup(a, b));
    }

    preRoundMatchups.sort();

    // Now pair the pre round matchups into how the first fully populated
    // elimination round should be played.

    // Set the first half of the initial matchups as first named
    List<_GroupKnockoutMatchup> firstNamedMatchups =
        preRoundMatchups.sublist(0, preRoundMatchups.length ~/ 2);

    // The other half is the pool to make the matchups from
    List<_GroupKnockoutMatchup> matchupPool = preRoundMatchups
        .sublist(preRoundMatchups.length ~/ 2)
        .sortedBy(
          // Invert the group sorting to get the members of the same group
          // into opposite tournament tree branches
          (m) => _GroupQualification(
            group: m.getHigherPlaced().group * -1,
            place: m.getHigherPlaced().place,
          ),
        )
        .toList();

    List<_GroupKnockoutMatchup> secondNamedMatchups = [];

    // Match each first named matchup with the worst rated available
    // matchup from the pool while avoiding group rematches.
    for (_GroupKnockoutMatchup matchup in firstNamedMatchups) {
      _GroupKnockoutMatchup secondNamed = matchupPool
              .where((m) => !matchup.hasOverlappingGroups(m))
              .lastOrNull ??
          matchupPool.last;

      matchupPool.remove(secondNamed);

      secondNamedMatchups.add(secondNamed);
    }

    // Convert the matchups into actual seeds that will grow into those matchups
    // in a SingleElimination tournament tree

    List<_GroupKnockoutMatchup> seededMatchups = [
      ...firstNamedMatchups,
      ...secondNamedMatchups.reversed,
    ];

    List<int> groupKnockoutSeeds = [];
    for (_GroupKnockoutMatchup match in seededMatchups) {
      groupKnockoutSeeds.add(qualifications.indexOf(match.a));
    }
    for (_GroupKnockoutMatchup match in seededMatchups.reversed) {
      if (match.b != null) {
        groupKnockoutSeeds.add(qualifications.indexOf(match.b!));
      }
    }

    return groupKnockoutSeeds;
  }

  List<_GroupQualification> _createGroupQualifications() {
    int places = numQualifications ~/ numGroups;

    List<_GroupQualification> qualifications = [
      for (int place = 0; place < places; place += 1)
        for (int group = 0; group < numGroups; group += 1)
          _GroupQualification(group: group, place: place),
    ];

    List<MatchParticipant<P>> groupRanking = targetRanking.ranks;
    int remainder = numQualifications % numGroups;
    List<MatchParticipant<P>> remainingQualifications = groupRanking.sublist(
      qualifications.length,
      qualifications.length + remainder,
    );

    for ((int, MatchParticipant<P>) indexedQualification
        in remainingQualifications.indexed) {
      int i = indexedQualification.$1;
      MatchParticipant<P> qualification = indexedQualification.$2;

      P? player = qualification.resolvePlayer();
      if (player == null) {
        qualifications.add(_GroupQualification(group: i, place: places));
        continue;
      }
      int group = targetRanking.groupPhase.getGroupOfPlayer(player);
      qualifications.add(_GroupQualification(group: group, place: places));
    }

    return qualifications;
  }

  /// Returns a power of two that is immediately smaller than
  /// or equal to [from].
  ///
  /// Only works with [from] >= 1
  int _getPreviousPowerOfTwo(int from) {
    int shifts = 0;
    while (from > 1) {
      from >>= 1;
      shifts += 1;
    }

    return pow(2, shifts) as int;
  }
}

/// A place in a group that qualifies its occupant for the elimination round
class _GroupQualification implements Comparable<_GroupQualification> {
  /// Create a [_GroupQualification] from finishing [place] in [group]
  _GroupQualification({
    required this.group,
    required this.place,
  });

  final int group;
  final int place;

  @override
  int compareTo(other) {
    int placeComparison = place.compareTo(other.place);
    if (placeComparison != 0) {
      return placeComparison;
    }

    int groupComparison = group.compareTo(other.group);

    return groupComparison;
  }
}

/// The first matchup of two [_GroupQualification]s in the elimination round
class _GroupKnockoutMatchup implements Comparable<_GroupKnockoutMatchup> {
  /// Creates a [_GroupKnockoutMatchup] between [a] and [b].
  ///
  /// Set [b] to `null` to give a bye to [a].
  _GroupKnockoutMatchup(
    this.a,
    this.b,
  );

  final _GroupQualification a;

  /// [b] being `null` signals a bye
  final _GroupQualification? b;

  _GroupQualification getHigherPlaced() {
    if (b == null) {
      return a;
    }

    int comparison = a.compareTo(b!);

    return comparison == -1 ? a : b!;
  }

  @override
  int compareTo(other) {
    return getHigherPlaced().compareTo(other.getHigherPlaced());
  }

  bool hasOverlappingGroups(_GroupKnockoutMatchup other) {
    bool aHasOverlap = a.group == other.a.group || a.group == other.b?.group;
    bool bHasOverlap = false;
    if (b != null) {
      bHasOverlap = b!.group == other.a.group || b!.group == other.b?.group;
    }

    return aHasOverlap || bHasOverlap;
  }
}
