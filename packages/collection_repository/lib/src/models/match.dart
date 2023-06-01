import 'package:collection_repository/src/expansion_tree/expanded_field.dart';
import 'package:collection_repository/src/utils/model_converter.dart'
    as model_converter;
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:collection_repository/collection_repository.dart';
// ignore: unused_import
import 'package:flutter/foundation.dart';

part 'generated/match.freezed.dart';
part 'generated/match.g.dart';

@freezed
class Match extends Model with _$Match {
  const Match._();

  /// A badminton match between [team1] and [team2].
  ///
  /// The match is being played in a [competition] on a [court]. The [status] of
  /// the Match dictates the administrative stage it is in. Eventually
  /// the [winner] will be saved to the Match object. If one of the players
  /// decides to upload a photo of the handwritten [resultCard] via the app its
  /// filepath is also included here. This would save a walk to the
  /// tournament admin desk.
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
      _$MatchFromJson(json..cleanUpExpansions(expandedFields));

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
    Map<String, dynamic> json = toJson();
    return json..collapseExpansions(expandedFields);
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
