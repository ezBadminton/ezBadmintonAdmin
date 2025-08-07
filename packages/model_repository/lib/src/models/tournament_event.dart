import 'package:model_repository/model_repository.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
// ignore: unused_import
import 'package:flutter/foundation.dart';

part 'generated/tournament_event.freezed.dart';
part 'generated/tournament_event.g.dart';

@freezed
class TournamentEvent extends Model with _$TournamentEvent {
  const TournamentEvent._();

  /// The [TournamentEvent] currently being administrated.
  ///
  /// On first start, the admin app mandates the creation of a tournament by
  /// asking for a [title]. From then the `tournaments` collection only
  /// contains one [TournamentEvent] object. The tournament can be further configured
  /// afterwards.
  ///
  /// [useAgeGroups] states if the [Competition]s in the tournament are
  /// categorized by [AgeGroup]s.
  /// Analog for [usePlayingLevels] and [PlayingLevel]s.
  factory TournamentEvent({
    required String id,
    required DateTime created,
    required DateTime updated,
    required String title,
    required bool useAgeGroups,
    required bool usePlayingLevels,
    required bool dontReprintGameSheets,
    required bool printQrCodes,
    required int playerRestTime,
  }) = _TournamentEvent;

  factory TournamentEvent.fromJson(Map<String, dynamic> json) =>
      _$TournamentEventFromJson(json);

  factory TournamentEvent.newTournament(String title) => TournamentEvent(
        id: '',
        created: DateTime.now().toUtc(),
        updated: DateTime.now().toUtc(),
        title: title,
        useAgeGroups: false,
        usePlayingLevels: false,
        dontReprintGameSheets: true,
        printQrCodes: true,
        playerRestTime: 20,
      );
}

