import 'package:collection_repository/src/models/models.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
// ignore: unused_import
import 'package:flutter/foundation.dart';

part 'generated/tournament.freezed.dart';
part 'generated/tournament.g.dart';

@freezed
class Tournament extends Model with _$Tournament {
  const Tournament._();

  /// The [Tournament] currently being administrated.
  ///
  /// On first start, the admin app mandates the creation of a tournament by
  /// asking for a [title]. From then the `tournaments` collection only
  /// contains one [Tournament] object. The tournament can be further configured
  /// afterwards.
  ///
  /// [useAgeGroups] states if the [Competition]s in the tournament are
  /// categorized by [AgeGroup]s.
  /// Analog for [usePlayingLevels] and [PlayingLevel]s.
  factory Tournament({
    required String id,
    required DateTime created,
    required DateTime updated,
    required String title,
    required bool useAgeGroups,
    required bool usePlayingLevels,
    required bool dontReprintGameSheets,
    required bool printQrCodes,
    required int playerRestTime,
    required QueueMode queueMode,
  }) = _Tournament;

  factory Tournament.fromJson(Map<String, dynamic> json) =>
      _$TournamentFromJson(json);

  factory Tournament.newTournament(String title) => Tournament(
        id: '',
        created: DateTime.now().toUtc(),
        updated: DateTime.now().toUtc(),
        title: title,
        useAgeGroups: false,
        usePlayingLevels: false,
        dontReprintGameSheets: true,
        printQrCodes: true,
        playerRestTime: 20,
        queueMode: QueueMode.manual,
      );

  @override
  Map<String, dynamic> toCollapsedJson() {
    return toJson();
  }
}

enum QueueMode {
  /// Match starting and court assignment are done manually.
  manual,

  /// The match starting is done manually and the courts are assigned
  /// automatically. The first available court is chosen.
  autoCourtAssignment,

  /// The matches are automatically started as soon as a court becomes available
  /// and the players had their minimum rest time.
  ///
  /// The matches are ordered in a round robin from all competitions running
  /// in parallel.
  auto,
}
