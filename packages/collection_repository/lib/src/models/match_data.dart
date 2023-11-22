import 'package:collection_repository/src/expansion_tree/expanded_field.dart';
import 'package:collection_repository/src/utils/model_converter.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:collection_repository/collection_repository.dart';
// ignore: unused_import
import 'package:flutter/foundation.dart';

part 'generated/match_data.freezed.dart';
part 'generated/match_data.g.dart';

@freezed
class MatchData extends Model with _$MatchData {
  const MatchData._();

  /// A badminton match's data in a [Competition].
  ///
  /// The match is assigned to a [court]. The [status] of the Match signals if
  /// the match was a walkover. The [sets] of the match are stored as a List
  /// of [MatchSet]s. When it is in progress the [startTime] is set and when it
  /// conculded the [endTime] is set. If one of the players decides to upload a
  /// photo of the handwritten [resultCard] via the app its filepath is included
  /// here. This would save a walk to the tournament admin desk.
  ///
  /// The [MatchData] class can exist without explicitly naming the opponent
  /// [Team]s because those are functionally dependent on the [Competition]s
  /// draw  (which is just a List of [Team]s), its tournament mode settings
  /// and on the match results. Since those three inputs are stored they can
  /// always be used to reconstruct who is playing in a particular [MatchData].
  /// This reconstruction can also be referred to as "hydrating" the tournament
  /// mode. This way a match can also be assigned to a court before the
  /// opponents are even determined. For example the final can be put on
  /// center court while the semi-finals are still ongoing.
  const factory MatchData({
    required String id,
    required DateTime created,
    required DateTime updated,
    required List<MatchSet> sets,
    Court? court,
    required List<Team> withdrawnTeams,
    DateTime? courtAssignmentTime,
    DateTime? startTime,
    DateTime? endTime,
    String? resultCard,
    required bool gameSheetPrinted,
  }) = _MatchData;

  factory MatchData.fromJson(Map<String, dynamic> json) =>
      _$MatchDataFromJson(json..cleanUpExpansions(expandedFields));

  factory MatchData.newMatch() => MatchData(
        id: '',
        created: DateTime.now().toUtc(),
        updated: DateTime.now().toUtc(),
        sets: const [],
        withdrawnTeams: const [],
        gameSheetPrinted: false,
      );

  static const List<ExpandedField> expandedFields = [
    ExpandedField(
      model: MatchSet,
      key: 'sets',
      isRequired: true,
      isSingle: false,
    ),
    ExpandedField(
      model: Court,
      key: 'court',
      isRequired: false,
      isSingle: true,
    ),
    ExpandedField(
      model: Team,
      key: 'withdrawnTeams',
      isRequired: true,
      isSingle: false,
    ),
  ];

  @override
  Map<String, dynamic> toCollapsedJson() {
    Map<String, dynamic> json = toJson();
    return json..collapseExpansions(expandedFields);
  }
}
