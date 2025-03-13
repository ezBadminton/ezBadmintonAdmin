import 'package:equatable/equatable.dart';
import 'package:model_repository/model_repository.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
// ignore: unused_import
import 'package:flutter/foundation.dart';
import 'package:model_repository/src/nullable_datetime.dart';

part 'generated/tournament_match.freezed.dart';
part 'generated/tournament_match.g.dart';

@Freezed(toJson: false)
class TournamentMatch extends Model with _$TournamentMatch {
  const TournamentMatch._();

  @JsonSerializable(explicitToJson: true, createToJson: false)
  const factory TournamentMatch({
    required String id,
    @ZeroDateTimeConverter() required DateTime created,
    @ZeroDateTimeConverter() required DateTime updated,
    @JsonKey(name: 'sets', defaultValue: MultiRelation.new)
    required MultiRelation<MatchSet> setsRel,
    @JsonKey(name: 'court', defaultValue: SingleRelation.new)
    required SingleRelation<Court> courtRel,
    @JsonKey(name: 'withdrawnTeams', defaultValue: MultiRelation.new)
    required MultiRelation<Team> withdrawnTeamsRel,
    @NullableDateTimeConverter() DateTime? courtAssignmentTime,
    @NullableDateTimeConverter() DateTime? startTime,
    @NullableDateTimeConverter() DateTime? endTime,
    required Slot slot1,
    required Slot slot2,
    @JsonKey(name: 'winner', defaultValue: SingleRelation.new)
    required SingleRelation<Team> winnerRel,
    @JsonKey(name: 'walkover') required bool isWalkover,
    String? resultCard,
    @JsonKey(defaultValue: false) required bool gameSheetPrinted,
  }) = _TournamentMatch;

  List<MatchSet> get sets => setsRel.models;
  Court? get court => courtRel.model;
  List<Team> get withdrawnTeams => withdrawnTeamsRel.models;
  Team? get winner => winnerRel.model;
  bool get isBye => slot1.isBye || slot2.isBye;
  List<Player> get players =>
      [slot1, slot2].expand<Player>((s) => s.team?.players ?? []).toList();

  String get tournamentPlanId => 't-${id.substring(2, 17)}';

  factory TournamentMatch.fromJson(Map<String, dynamic> json) =>
      _$TournamentMatchFromJson(json);

  @override
  Map<String, dynamic> toJson() {
    throw UnimplementedError();
  }
}

class Slot extends Equatable {
  const Slot({
    required this.id,
    required this.teamRel,
    required this.bye,
  });

  Slot.fromTeam(Team team)
      : id = -1,
        teamRel = SingleRelation.fromModel(team),
        bye = null;

  final int id;
  final SingleRelation<Team> teamRel;
  final ByeStatus? bye;

  Team? get team => teamRel.model;
  bool get isBye => bye != null;
  bool get isDrawnBye => bye == ByeStatus.drawnBye;

  factory Slot.fromJson(Map<String, dynamic> json) {
    int id = json["id"];
    ByeStatus? bye;
    String teamId = json["occupant"];
    if (teamId == "db") {
      bye = ByeStatus.drawnBye;
      teamId = "";
    } else if (teamId == "b") {
      bye = ByeStatus.bye;
      teamId = "";
    }
    var team = SingleRelation<Team>(relationId: teamId);
    return Slot(id: id, teamRel: team, bye: bye);
  }

  @override
  List<Object> get props => [id];
}
