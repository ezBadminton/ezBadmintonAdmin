import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:model_repository/model_repository.dart';
// ignore: unused_import
import 'package:flutter/foundation.dart';

part 'generated/scheduled_round.freezed.dart';
part 'generated/scheduled_round.g.dart';

@freezed
class ScheduledRound extends Model with _$ScheduledRound {
  const ScheduledRound._();

  const factory ScheduledRound({
    required String id,
    required DateTime created,
    required DateTime updated,
    @JsonKey(name: 'matches')
    required MultiRelation<ScheduledMatch> matchesRel,
    required int roundIndex,
    @JsonKey(name: 'competition')
    required SingleRelation<Competition> competitionRel,
  }) = _ScheduledRound;

  List<ScheduledMatch> get matches => matchesRel.models;
  Competition get competition => competitionRel.model!;

  factory ScheduledRound.fromJson(Map<String, dynamic> json) =>
      _$ScheduledRoundFromJson(json);
}
