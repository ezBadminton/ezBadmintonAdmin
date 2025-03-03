import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:model_repository/model_repository.dart';
// ignore: unused_import
import 'package:flutter/foundation.dart';

part 'generated/team.freezed.dart';
part 'generated/team.g.dart';

@freezed
class Team extends Model with _$Team {
  const Team._();

  /// A team of [players].
  ///
  /// For singles competitions the Teams only have one player. Two in doubles.
  /// Should a team not be able to complete their games in a competition they
  /// are marked as [resigned].
  const factory Team({
    required String id,
    required DateTime created,
    required DateTime updated,
    @MultiRelationPlayerConverter()
    @JsonKey(name: 'players')
    required MultiRelation<Player> playersRel,
    required bool resigned,
  }) = _Team;

  List<Player> get players => playersRel.models;

  factory Team.newTeam({List<Player> players = const []}) {
    return Team(
      id: '',
      created: DateTime.now().toUtc(),
      updated: DateTime.now().toUtc(),
      playersRel: MultiRelation.fromModels(players),
      resigned: false,
    );
  }

  factory Team.fromJson(Map<String, dynamic> json) => _$TeamFromJson(json);
}
