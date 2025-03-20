import 'package:freezed_annotation/freezed_annotation.dart';

// ignore: unused_import
import 'package:flutter/foundation.dart';

part 'generated/match_set.freezed.dart';
part 'generated/match_set.g.dart';

@freezed
class MatchSet with _$MatchSet {
  const MatchSet._();

  /// One set in a badminton match. Once the set results are entered, the
  /// match's [MatchData.sets] list is filled with the [MatchSet]s.
  ///
  /// A badminton match usually consists of 2-3 sets with the winning team
  /// reaching 21 points (2 points clear) first.
  const factory MatchSet({
    required int team1Points,
    required int team2Points,
  }) = _MatchSet;

  factory MatchSet.fromJson(List json) => MatchSet(
        team1Points: json[0],
        team2Points: json[1],
      );
}
