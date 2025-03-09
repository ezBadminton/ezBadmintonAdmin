import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:model_repository/model_repository.dart';
// ignore: unused_import
import 'package:flutter/foundation.dart';

part 'generated/schedule.freezed.dart';
part 'generated/schedule.g.dart';

@freezed
class Schedule extends Model with _$Schedule {
  const Schedule._();

  const factory Schedule({
    required String id,
    required DateTime created,
    required DateTime updated,
    @JsonKey(name: 'roundQueue')
    required MultiRelation<ScheduledRound> roundQueueRel,
  }) = _Schedule;

  List<ScheduledRound> get roundQueue => roundQueueRel.models;
  List<ScheduledMatch> get matches =>
      roundQueue.expand((round) => round.matches).toList();

  factory Schedule.fromJson(Map<String, dynamic> json) =>
      _$ScheduleFromJson(json);
}
