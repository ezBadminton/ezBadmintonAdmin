import 'package:collection_repository/src/models/model_converter.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
// ignore: unused_import
import 'package:flutter/foundation.dart';
import 'package:collection_repository/src/models/models.dart';

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
    required List<Player> players,
    required bool resigned,
  }) = _Team;

  factory Team.newTeam({List<Player> players = const []}) {
    return Team(
      id: '',
      created: DateTime.now(),
      updated: DateTime.now(),
      players: players,
      resigned: false,
    );
  }

  factory Team.fromJson(Map<String, dynamic> json) =>
      _$TeamFromJson(ModelConverter.convertExpansions(json, expandedFields));

  static const List<ExpandedField> expandedFields = [
    ExpandedField(
      model: Player,
      key: 'players',
      isRequired: true,
      isSingle: false,
    ),
  ];

  @override
  Map<String, dynamic> toCollapsedJson() {
    Map<String, dynamic> json = toJson();
    return ModelConverter.collapseExpansions(json, expandedFields);
  }
}
