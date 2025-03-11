import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:model_repository/model_repository.dart';
// ignore: unused_import
import 'package:flutter/foundation.dart';

part 'generated/player_block.freezed.dart';
part 'generated/player_block.g.dart';

@freezed
class PlayerBlock with _$PlayerBlock {
  const PlayerBlock._();

  const factory PlayerBlock({
    required PlayerBlockMode mode,
    @JsonKey(
      name: 'blockingMatch',
      defaultValue: SingleRelation<TournamentMatch>.new,
    )
    required SingleRelation<TournamentMatch> blockingMatchRel,
    DateTime? restUntil,
  }) = _PlayerBlock;

  TournamentMatch? get blockingMatch => blockingMatchRel.model;

  factory PlayerBlock.fromJson(Map<String, dynamic> json) =>
      _$PlayerBlockFromJson(json);
}

enum PlayerBlockMode {
  playing,
  resting,
}
