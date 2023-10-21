import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:collection_repository/collection_repository.dart';

// ignore: unused_import
import 'package:flutter/foundation.dart';

part 'generated/match_set.freezed.dart';
part 'generated/match_set.g.dart';

@freezed
class MatchSet extends Model with _$MatchSet {
  const MatchSet._();

  /// One set in a badminton match. Once the set results are entered, the
  /// match's [MatchData.sets] list is filled with the [MatchSet]s.
  ///
  /// A badminton match usually consists of 2-3 sets with the winning team
  /// reaching 21 points (2 points clear) first.
  const factory MatchSet({
    required String id,
    required DateTime created,
    required DateTime updated,
    required int team1Points,
    required int team2Points,
  }) = _MatchSet;

  factory MatchSet.fromJson(Map<String, dynamic> json) =>
      _$MatchSetFromJson(json);

  factory MatchSet.newMatchSet({
    required int team1Points,
    required int team2Points,
  }) =>
      MatchSet(
        id: '',
        created: DateTime.now().toUtc(),
        updated: DateTime.now().toUtc(),
        team1Points: team1Points,
        team2Points: team2Points,
      );

  @override
  Map<String, dynamic> toCollapsedJson() {
    return toJson();
  }
}
