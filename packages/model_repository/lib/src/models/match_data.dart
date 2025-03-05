import 'package:model_repository/model_repository.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
// ignore: unused_import
import 'package:flutter/foundation.dart';
import 'package:model_repository/src/nullable_datetime.dart';
import 'package:model_repository/src/relations.dart';

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
    @JsonKey(name: 'sets') required MultiRelation<MatchSet> setsRel,
    @JsonKey(name: 'court') required SingleRelation<Court> courtRel,
    @JsonKey(name: 'withdrawnTeams')
    required MultiRelation<Team> withdrawnTeamsRel,
    @NullableDateTimeConverter() DateTime? courtAssignmentTime,
    @NullableDateTimeConverter() DateTime? startTime,
    @NullableDateTimeConverter() DateTime? endTime,
    String? resultCard,
    required bool gameSheetPrinted,
  }) = _MatchData;

  List<MatchSet> get sets => setsRel.models;
  Court? get court => courtRel.model;
  List<Team> get withdrawnTeams => withdrawnTeamsRel.models;

  factory MatchData.fromJson(Map<String, dynamic> json) =>
      _$MatchDataFromJson(json);

  factory MatchData.newMatch() => MatchData(
        id: '',
        created: DateTime.now().toUtc(),
        updated: DateTime.now().toUtc(),
        setsRel: MultiRelation(),
        courtRel: SingleRelation(),
        withdrawnTeamsRel: MultiRelation(),
        gameSheetPrinted: false,
      );
}
