import 'package:collection_repository/collection_repository.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
// ignore: unused_import
import 'package:flutter/foundation.dart';

part 'generated/playing_level.freezed.dart';
part 'generated/playing_level.g.dart';

@freezed
class PlayingLevel extends Model with _$PlayingLevel {
  const PlayingLevel._();

  /// The playing level of a player.
  ///
  /// The higher the index the stronger the player. Each tournament can define
  /// its own playing levels to make competitions more balanced.
  const factory PlayingLevel({
    required String id,
    required DateTime created,
    required DateTime updated,
    required String name,
    required int index,
  }) = _PlayingLevel;

  factory PlayingLevel.fromJson(Map<String, dynamic> json) =>
      _$PlayingLevelFromJson(json);

  factory PlayingLevel.newPlayingLevel(
    String name,
    int index,
  ) =>
      PlayingLevel(
        id: '',
        created: DateTime.now().toUtc(),
        updated: DateTime.now().toUtc(),
        name: name,
        index: index,
      );

  @override
  Map<String, dynamic> toCollapsedJson() {
    return toJson();
  }
}
