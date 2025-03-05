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
sealed class Tournament with _$Tournament {
  const Tournament._();

  @FreezedUnionValue('RoundRobin')
  @JsonSerializable(explicitToJson: true, createToJson: false)
  const factory Tournament.roundRobin({
    @JsonKey(name: 'editable', readValue: Tournament._mapEditableMatches)
    required MultiRelation<MatchData> editableRel,
    @JsonKey(readValue: Tournament._mapSlotOccupants)
    required List<List<TournamentMatch>> rounds,
    required List<MatchMetrics> metrics,
  }) = RoundRobin;

  @FreezedUnionValue('SingleElimination')
  @JsonSerializable(explicitToJson: true, createToJson: false)
  const factory Tournament.singleElimination({
    @JsonKey(name: 'editable', readValue: Tournament._mapEditableMatches)
    required MultiRelation<MatchData> editableRel,
    @JsonKey(readValue: Tournament._mapSlotOccupants)
    required List<List<TournamentMatch>> rounds,
  }) = SingleElimination;

  @FreezedUnionValue('SingleEliminationWithConsolation')
  @JsonSerializable(explicitToJson: true, createToJson: false)
  const factory Tournament.singleEliminationWithConsolation({
    @JsonKey(name: 'editable', readValue: Tournament._mapEditableMatches)
    required MultiRelation<MatchData> editableRel,
    required ConsolationBracket mainBracket,
  }) = SingleEliminationWithConsolation;

  @FreezedUnionValue('DoubleElimination')
  @JsonSerializable(explicitToJson: true, createToJson: false)
  const factory Tournament.doubleElimination({
    @JsonKey(name: 'editable', readValue: Tournament._mapEditableMatches)
    required MultiRelation<MatchData> editableRel,
    @JsonKey(readValue: Tournament._mapSlotOccupants)
    required List<List<TournamentMatch>> rounds,
  }) = DoubleElimination;

  @FreezedUnionValue('GroupKnockout')
  @JsonSerializable(explicitToJson: true, createToJson: false)
  const factory Tournament.groupKnockout({
    @JsonKey(name: 'editable', readValue: Tournament._mapEditableMatches)
    required MultiRelation<MatchData> editableRel,
    @JsonKey(readValue: TournamentPlan.enrichMatchData)
    required GroupPhase groupPhase,
    @JsonKey(name: 'koPhase', readValue: TournamentPlan.enrichMatchData)
    required Tournament knockoutPhase,
  }) = GroupKnockout;

  List<MatchData> get editable => editableRel.models;

  factory Tournament.fromJson(Map<String, dynamic> json) =>
      _$TournamentFromJson(json);

  static Object? _mapEditableMatches(Map json, String key) {
    var matchDataMap = Map<int, String>.from(json["matchData"]);
    var matchIds = List<int>.from(json[key] ?? []);
    matchIds = matchIds.where((id) => matchDataMap.containsKey(id)).toList();
    return matchIds.map((id) => matchDataMap[id]!).toList();
  }

  static Object? _mapSlotOccupants(Map json, String key) {
    var matchDataMap = Map<int, String>.from(json["matchData"]);
    var slotMap = Map<int, String>.from(json["slots"]);
    var rounds = List.from(json[key]);
    return rounds.map((r) {
      var round = List.from(r);
      return round.map((m) {
        var match = Map<String, dynamic>.from(m);
        match["matchData"] = matchDataMap[match["id"]] ?? "";
        match["slot1"] = slotMap[match["slot1"]];
        match["slot2"] = slotMap[match["slot2"]];
        return match;
      }).toList();
    }).toList();
  }
}

class TournamentMatch {
  TournamentMatch({
    required this.aRel,
    required this.bRel,
    required this.matchDataRel,
    required this.bye,
  });

  final SingleRelation<Team> aRel;
  final SingleRelation<Team> bRel;
  final SingleRelation<MatchData> matchDataRel;
  final ByeStatus? bye;

  Team? get a => aRel.model;
  Team? get b => bRel.model;
  MatchData? get matchData => matchDataRel.model;

  factory TournamentMatch.fromJson(Map<String, dynamic> json) {
    ByeStatus? bye;
    String teamAId = json["slot1"] ?? "";
    String teamBId = json["slot2"] ?? "";
    var aDrawnBye = teamAId == "db";
    var bDrawnBye = teamBId == "db";
    var aBye = teamAId == "b";
    var bBye = teamBId == "b";
    if (aDrawnBye || bDrawnBye) {
      bye = ByeStatus.drawnBye;
    } else if (aBye || bBye) {
      bye = ByeStatus.bye;
    }
    teamAId = (aDrawnBye || aBye) ? "" : teamAId;
    teamBId = (bDrawnBye || bBye) ? "" : teamBId;

    var a = SingleRelation<Team>(relationId: teamAId);
    var b = SingleRelation<Team>(relationId: teamBId);
    var matchData = SingleRelation<MatchData>(relationId: json["matchData"]);

    return TournamentMatch(
      aRel: a,
      bRel: b,
      matchDataRel: matchData,
      bye: bye,
    );
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
  const ConsolationBracket({
    required this.rounds,
    this.consolations = const [],
  });

  @JsonKey(readValue: Tournament._mapSlotOccupants)
  final List<List<TournamentMatch>> rounds;
  final List<ConsolationBracket> consolations;

  factory ConsolationBracket.fromJson(Map<String, dynamic> json) =>
      _$ConsolationBracketFromJson(json);
}

@JsonSerializable(explicitToJson: true, createToJson: false)
class GroupPhase {
  const GroupPhase({
    required this.groupRounds,
    required this.groupMetrics,
    required this.groupTies,
    required this.unbrokenGroupTies,
    required this.crossGroupTies,
  });

  @JsonKey(readValue: GroupPhase._mapSlotOccupants)
  final List<List<List<TournamentMatch>>> groupRounds;
  final List<MatchMetrics> groupMetrics;
  @JsonKey(readValue: GroupPhase._mapGroupTieSlots)
  final List<List<List<SingleRelation<Team>>>> groupTies;
  @JsonKey(readValue: GroupPhase._mapGroupTieSlots)
  final List<List<List<SingleRelation<Team>>>> unbrokenGroupTies;
  @JsonKey(readValue: GroupPhase._mapCrossGroupTieSlots)
  final List<List<SingleRelation<Team>>> crossGroupTies;

  factory GroupPhase.fromJson(Map<String, dynamic> json) =>
      _$GroupPhaseFromJson(json);

  static Object? _mapSlotOccupants(Map json, String key) {
    var matchDataMap = Map<int, String>.from(json["matchData"]);
    var slotMap = Map<int, String>.from(json["slots"]);
    var rounds = List.from(json[key]);
    return rounds.map((groupRs) {
      var groupRounds = List.from(groupRs);
      return groupRounds.map((r) {
        var round = List.from(r);
        return round.map((m) {
          var match = Map<String, dynamic>.from(m);
          match["matchData"] = matchDataMap[match["id"]] ?? "";
          match["slot1"] = slotMap[match["slot1"]];
          match["slot2"] = slotMap[match["slot2"]];
          return match;
        });
      }).toList();
    }).toList();
  }

  static Object? _mapGroupTieSlots(Map json, String key) {
    var slotMap = Map<int, String>.from(json["slots"]);
    var groupTieList = List.from(json[key]);
    return groupTieList.map((gt) {
      var groupTies = List.of(gt);
      return groupTies.map((t) {
        var tie = List.of(t);
        tie.map((t) {
          var slotId = t as int;
          var teamId = slotMap[slotId];
          return teamId;
        });
      });
    });
  }

  static Object? _mapCrossGroupTieSlots(Map json, String key) {
    var slotMap = Map<int, String>.from(json["slots"]);
    var crossTies = List.from(json[key]);
    return crossTies.map((t) {
      var tie = List.of(t);
      tie.map((t) {
        var slotId = t as int;
        var teamId = slotMap[slotId];
        return teamId;
      });
    });
  }
}
