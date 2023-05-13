import 'package:collection_repository/src/models/model_converter.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:collection_repository/collection_repository.dart';
// ignore: unused_import
import 'package:flutter/foundation.dart';

part 'generated/match.freezed.dart';
part 'generated/match.g.dart';

@freezed
class Match extends Model with _$Match {
  const Match._();
  const factory Match({
    required String id,
    required DateTime created,
    required DateTime updated,
    required Competition competition,
    required Team team1,
    required Team team2,
    required Court court,
    required MatchStatus status,
    Team? winner,
    String? resultCard,
  }) = _Match;

  factory Match.fromJson(Map<String, dynamic> json) =>
      _$MatchFromJson(ModelConverter.convertExpansions(json, expandedFields));

  static const List<ExpandedField> expandedFields = [
    ExpandedField(
      model: Competition,
      key: 'competition',
      isRequired: true,
      isSingle: true,
    ),
    ExpandedField(model: Team, key: 'team1', isRequired: true, isSingle: true),
    ExpandedField(model: Team, key: 'team2', isRequired: true, isSingle: true),
    ExpandedField(model: Court, key: 'court', isRequired: true, isSingle: true),
    ExpandedField(
        model: Team, key: 'winner', isRequired: false, isSingle: true),
  ];

  @override
  Map<String, dynamic> toCollapsedJson() {
    Map<String, dynamic> json = this.toJson();
    return ModelConverter.collapseExpansions(json, expandedFields);
  }
}

enum MatchStatus {
  planned,
  calledOut,
  inProgress,
  cancelled,
  finished,
  walkover,
}
