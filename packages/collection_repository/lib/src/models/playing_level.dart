import 'package:collection_repository/collection_repository.dart';
import 'package:const_date_time/const_date_time.dart';
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

  static const PlayingLevel unrated = PlayingLevel(
    id: 'unrated',
    created: ConstDateTime(0),
    updated: ConstDateTime(0),
    name: '',
    index: -1,
  );

  factory PlayingLevel.fromJson(Map<String, dynamic> json) =>
      _$PlayingLevelFromJson(json);

  @override
  Map<String, dynamic> toCollapsedJson() {
    return this.toJson();
  }
}
