import 'package:collection/collection.dart';
import 'package:model_repository/model_repository.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'generated/tournament.freezed.dart';
part 'generated/tournament.g.dart';

typedef RoundList = List<List<Map<String, dynamic>>>;

@Freezed(
  unionKey: 'type',
  unionValueCase: FreezedUnionCase.pascal,
  toJson: false,
)
sealed class Tournament with _$Tournament implements MatchRoundList {
  const Tournament._();

  @FreezedUnionValue('RoundRobin')
  @With<DefaultRounds>()
  @With<RoundRobinTies>()
  @JsonSerializable(explicitToJson: true, createToJson: false)
  const factory Tournament.roundRobin({
    @JsonKey(name: 'editable', defaultValue: MultiRelation.new)
    required MultiRelation<TournamentMatch> editableRel,
    @JsonKey(name: 'rounds')
    required List<MultiRelation<TournamentMatch>> roundsRel,
    @JsonKey(name: 'entries') required List<List<Slot>> entriesRel,
    @JsonKey(name: 'finalRanking') required List<List<Slot>> finalRankingRel,
    required List<MatchMetrics> metrics,
    @JsonKey(name: 'ties') required List<List<Slot>> tiesRel,
    @JsonKey(name: 'unbrokenTies') required List<List<Slot>> unbrokenTiesRel,
  }) = RoundRobin;

  @FreezedUnionValue('SingleElimination')
  @With<DefaultRounds>()
  @With<DefaultRoundsRelations>()
  @JsonSerializable(explicitToJson: true, createToJson: false)
  const factory Tournament.singleElimination({
    @JsonKey(name: 'editable', defaultValue: MultiRelation.new)
    required MultiRelation<TournamentMatch> editableRel,
    @JsonKey(name: 'rounds')
    required List<MultiRelation<TournamentMatch>> roundsRel,
    @JsonKey(name: 'entries') required List<List<Slot>> entriesRel,
    @JsonKey(name: 'finalRanking') required List<List<Slot>> finalRankingRel,
  }) = SingleElimination;

  @FreezedUnionValue('SingleEliminationWithConsolation')
  @With<ConsolationRounds>()
  @JsonSerializable(explicitToJson: true, createToJson: false)
  factory Tournament.singleEliminationWithConsolation({
    @JsonKey(name: 'editable', defaultValue: MultiRelation.new)
    required MultiRelation<TournamentMatch> editableRel,
    @JsonKey(name: 'entries') required List<List<Slot>> entriesRel,
    @JsonKey(name: 'finalRanking') required List<List<Slot>> finalRankingRel,
    @JsonKey(readValue: Tournament._markRootBracket)
    required ConsolationBracket mainBracket,
  }) = SingleEliminationWithConsolation;

  @FreezedUnionValue('DoubleElimination')
  @With<DoubleEliminationRounds>()
  @JsonSerializable(explicitToJson: true, createToJson: false)
  factory Tournament.doubleElimination({
    @JsonKey(name: 'editable', defaultValue: MultiRelation.new)
    required MultiRelation<TournamentMatch> editableRel,
    @JsonKey(name: 'entries') required List<List<Slot>> entriesRel,
    @JsonKey(name: 'finalRanking') required List<List<Slot>> finalRankingRel,
    @JsonKey(name: 'winnerRounds')
    required List<MultiRelation<TournamentMatch>> winnerRoundsRel,
    @JsonKey(name: 'loserRounds')
    required List<MultiRelation<TournamentMatch>> loserRoundsRel,
    @JsonKey(name: 'final')
    required SingleRelation<TournamentMatch> finalMatchRel,
  }) = DoubleElimination;

  @FreezedUnionValue('GroupKnockout')
  @With<GroupKnockoutRounds>()
  @JsonSerializable(explicitToJson: true, createToJson: false)
  factory Tournament.groupKnockout({
    @JsonKey(name: 'editable', defaultValue: MultiRelation.new)
    required MultiRelation<TournamentMatch> editableRel,
    @JsonKey(name: 'entries') required List<List<Slot>> entriesRel,
    @JsonKey(name: 'finalRanking') required List<List<Slot>> finalRankingRel,
    required GroupPhase groupPhase,
    @JsonKey(name: 'koPhase') required Tournament knockoutPhase,
    @JsonKey(name: 'koStarted') required bool knockoutStarted,
  }) = GroupKnockout;

  List<TournamentMatch> get editable => editableRel.models;
  List<Team> get entries =>
      Tournament._unwrapTeams(entriesRel).flattened.toList();
  List<List<Team>> get finalRanking => Tournament._unwrapTeams(finalRankingRel);

  bool get matchesEnded {
    var allMatches = rounds.expand((r) => r);
    for (final match in allMatches) {
      if (match.winner == null && !match.isBye && !match.isWalkover) {
        return false;
      }
    }
    return true;
  }

  factory Tournament.fromJson(Map<String, dynamic> json) =>
      _$TournamentFromJson(json);

  static List<List<Team>> _unwrapTeams(List<List<Slot>> slots) {
    return slots.map((slotList) {
      return slotList
          .where((slot) => slot.team != null)
          .map((slot) => slot.team!)
          .toList();
    }).toList();
  }

  static List<List<TournamentMatch>> _unwrapMatches(
    List<MultiRelation<TournamentMatch>> matches,
  ) {
    return matches.map((r) => r.models).toList();
  }

  static Object? _markRootBracket(Map json, String key) {
    Map bracketJson = json[key];
    bracketJson["isRoot"] = true;
    return bracketJson;
  }
}

@JsonSerializable()
class MatchMetrics {
  const MatchMetrics({
    required this.numMatches,
    required this.wins,
    required this.losses,
    required this.numSets,
    required this.setWins,
    required this.setLosses,
    required this.pointWins,
    required this.pointLosses,
  });

  final int numMatches;
  final int wins;
  final int losses;
  final int numSets;
  final int setWins;
  final int setLosses;
  final int pointWins;
  final int pointLosses;

  int get setDifference => setWins - setLosses;
  int get pointDifference => pointWins - pointLosses;

  factory MatchMetrics.fromJson(Map<String, dynamic> json) =>
      _$MatchMetricsFromJson(json);
}

enum ByeStatus {
  bye,
  drawnBye,
}

@JsonSerializable(explicitToJson: true, createToJson: false)
class ConsolationBracket {
  ConsolationBracket({
    required this.roundsRel,
    this.consolations = const [],
    this.isRoot = false,
  });

  @JsonKey(name: 'rounds')
  final List<MultiRelation<TournamentMatch>> roundsRel;
  final List<ConsolationBracket> consolations;
  @JsonKey(defaultValue: false)
  final bool isRoot;

  @JsonKey(includeFromJson: false, includeToJson: false)
  late final (int, int) rankRange;

  List<List<TournamentMatch>> get rounds =>
      Tournament._unwrapMatches(roundsRel);

  factory ConsolationBracket.fromJson(Map<String, dynamic> json) {
    final bracket = _$ConsolationBracketFromJson(json);
    if (bracket.isRoot) {
      bracket.determineRankRange((-1, -1), null);
    }
    return bracket;
  }

  determineRankRange(
    (int, int) parentRange,
    ConsolationBracket? rightSibling,
  ) {
    int bestRank = rightSibling == null
        ? parentRange.$1 + 2
        : rightSibling.rankRange.$2 + 1;
    int worstRank = bestRank + (roundsRel.first.relationIds.length * 2) - 1;
    rankRange = (bestRank, worstRank);
    rightSibling = null;
    for (final child in consolations.reversed) {
      child.determineRankRange(rankRange, rightSibling);
      rightSibling = child;
    }
  }
}

@JsonSerializable(explicitToJson: true, createToJson: false)
class GroupPhase {
  const GroupPhase({
    required this.groups,
    required this.crossGroupTiesRel,
    required this.unbrokenCrossGroupTiesRel,
    required this.crossTiedRank,
  });

  final List<RoundRobin> groups;
  @JsonKey(name: 'crossGroupTies')
  final List<List<Slot>> crossGroupTiesRel;
  @JsonKey(name: 'unbrokenCrossGroupTies')
  final List<List<Slot>> unbrokenCrossGroupTiesRel;
  final int crossTiedRank;

  List<List<Team>> get crossGroupTies =>
      Tournament._unwrapTeams(crossGroupTiesRel);
  List<List<Team>> get unbrokenCrossGroupTies =>
      Tournament._unwrapTeams(unbrokenCrossGroupTiesRel);

  bool get groupPhaseEnded => groups.every((group) => group.matchesEnded);

  bool get hasTies =>
      crossGroupTies.isNotEmpty || groups.any((group) => group.ties.isNotEmpty);

  factory GroupPhase.fromJson(Map<String, dynamic> json) =>
      _$GroupPhaseFromJson(json);
}

mixin RoundRobinTies {
  List<MultiRelation<TournamentMatch>> get roundsRel;
  List<List<Slot>> get tiesRel;
  List<List<Slot>> get unbrokenTiesRel;

  List<List<Team>> get ties => Tournament._unwrapTeams(tiesRel);
  List<List<Team>> get unbrokenTies => Tournament._unwrapTeams(unbrokenTiesRel);
}

abstract class MatchRoundList {
  List<List<TournamentMatch>> get rounds;
}

mixin DefaultRounds {
  List<MultiRelation<TournamentMatch>> get roundsRel;
  List<List<TournamentMatch>> get rounds =>
      Tournament._unwrapMatches(roundsRel);
}

mixin DefaultRoundsRelations {
  List<MultiRelation<TournamentMatch>> get roundsRel;
}

mixin ConsolationRounds {
  ConsolationBracket get mainBracket;

  List<List<TournamentMatch>> get rounds {
    if (_rounds == null) {
      _makeRounds();
    }
    return _rounds!;
  }

  ConsolationBracket bracketOfMatch(TournamentMatch match) {
    if (_bracketMap == null) {
      _makeRounds();
    }
    return _bracketMap![match]!;
  }

  List<List<TournamentMatch>>? _rounds;
  Map<TournamentMatch, ConsolationBracket>? _bracketMap;

  _makeRounds() {
    var stack = <ConsolationBracket>[mainBracket];
    var orderedBrackets = <ConsolationBracket>[];
    var bracketMap = <TournamentMatch, ConsolationBracket>{};

    for (int l = 1; l > 0; l = stack.length) {
      var current = stack[l - 1];
      stack = stack.sublist(0, l - 1);
      stack.addAll(current.consolations);
      orderedBrackets.add(current);
    }

    var maxNumRounds = mainBracket.rounds.length;
    var groupedRounds =
        List<List<TournamentMatch>>.generate(maxNumRounds, (_) => []);
    for (var bracket in orderedBrackets) {
      var numRounds = bracket.rounds.length;
      for (var (i, r) in bracket.rounds.indexed) {
        var groupI = i + (maxNumRounds - numRounds);
        groupedRounds[groupI].addAll(r);
        for (var match in r) {
          bracketMap[match] = bracket;
        }
      }
    }
    _rounds = groupedRounds;
    _bracketMap = bracketMap;
  }
}

mixin DoubleEliminationRounds {
  List<MultiRelation<TournamentMatch>> get winnerRoundsRel;
  List<MultiRelation<TournamentMatch>> get loserRoundsRel;
  SingleRelation<TournamentMatch> get finalMatchRel;

  List<List<TournamentMatch>> get winnerRounds =>
      Tournament._unwrapMatches(winnerRoundsRel);
  List<List<TournamentMatch>> get loserRounds =>
      Tournament._unwrapMatches(loserRoundsRel);
  TournamentMatch get finalMatch => finalMatchRel.model!;

  List<List<TournamentMatch>> get rounds {
    if (_rounds == null) {
      _makeRounds();
    }
    return _rounds!;
  }

  List<List<TournamentMatch>>? _rounds;

  _makeRounds() {
    var rounds = <List<TournamentMatch>>[];

    for (var i = 0; i < winnerRounds.length; i++) {
      var loserRoundI = i - 1;
      var winnerMatches = winnerRounds[i];
      if (loserRoundI >= 0) {
        var minorMatches = loserRounds[2 * loserRoundI];
        var majorMatches = loserRounds[2 * loserRoundI + 1];

        rounds.add([...winnerMatches, ...minorMatches]);
        rounds.add(majorMatches);
      } else {
        rounds.add(winnerMatches);
      }
    }
    rounds.add([finalMatch]);

    _rounds = rounds;
  }
}

mixin GroupKnockoutRounds {
  GroupPhase get groupPhase;
  Tournament get knockoutPhase;

  List<List<TournamentMatch>> get rounds {
    _rounds ??= _makeRounds();
    return _rounds!;
  }

  List<List<TournamentMatch>>? _rounds;

  List<List<TournamentMatch>> _makeRounds() {
    var rounds = <List<TournamentMatch>>[];
    var lastGroup = groupPhase.groups.last;
    var maxNumRounds = lastGroup.rounds.length;

    for (int i = 0; i < maxNumRounds; i++) {
      var groupRounds = groupPhase.groups
          .map((g) => g.rounds.elementAtOrNull(i))
          .whereType<List<TournamentMatch>>()
          .toList();
      var maxNumMatches = groupRounds.last.length;
      var superGroupRound = <TournamentMatch>[];
      for (int i = 0; i < maxNumMatches; i++) {
        var matchesAtIndex = groupRounds
            .map((group) => group.elementAtOrNull(i))
            .whereType<TournamentMatch>()
            .toList();
        superGroupRound.addAll(matchesAtIndex);
      }
      rounds.add(superGroupRound);
    }

    rounds.addAll(knockoutPhase.rounds);

    return rounds;
  }
}
