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
  const factory Team({
    required String id,
    required DateTime created,
    required DateTime updated,
    required List<Player> players,
    required bool resigned,
  }) = _Team;

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
    Map<String, dynamic> json = this.toJson();
    return ModelConverter.collapseExpansions(json, expandedFields);
  }
}
