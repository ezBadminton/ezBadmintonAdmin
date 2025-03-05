import 'package:collection/collection.dart';
import 'package:model_repository/model_repository.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
// ignore: unused_import
import 'package:flutter/foundation.dart';

part 'generated/registration.freezed.dart';
part 'generated/registration.g.dart';

@freezed
class Registration extends Model with _$Registration {
  const Registration._();

  /// A [Registration] is a tuple of a [Team] and a [Competition]
  /// where the team takes part in the competition.
  const factory Registration({
    required String id,
    required DateTime created,
    required DateTime updated,
    @JsonKey(name: 'competition')
    required SingleRelation<Competition> competitionRel,
    @JsonKey(name: 'team')
    required SingleRelation<Team> teamRel,
    required bool withdrawn,
  }) = _Registration;

  Competition get competition => competitionRel.model!;
  Team get team => teamRel.model!;

  factory Registration.fromJson(Map<String, dynamic> json) =>
      _$RegistrationFromJson(json);

  factory Registration.newRegistration({
    required Competition competition,
    required Team team,
  }) =>
      Registration(
        id: '',
        created: DateTime.now().toUtc(),
        updated: DateTime.now().toUtc(),
        competitionRel: SingleRelation.fromModel(competition),
        teamRel: SingleRelation.fromModel(team),
        withdrawn: false,
      );

  Player? getPartner(Player player) {
    assert(team.players.contains(player));
    return team.players.whereNot((p) => p == player).firstOrNull;
  }

  Team? getPartnerTeam(Player player) {
    var partner = getPartner(player);
    if (partner == null || competition.teamSize == 1) {
      return null;
    }
    return competition.registrations.firstWhereOrNull(
      (t) => t.players.length == 1 && t.players[0] == partner,
    );
  }

  int? get seed {
    var seed = competition.seeds.indexOf(team);
    if (seed == -1) {
      return null;
    }
    return seed;
  }
}
