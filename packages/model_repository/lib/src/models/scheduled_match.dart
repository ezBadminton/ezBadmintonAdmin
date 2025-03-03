import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:model_repository/model_repository.dart';
// ignore: unused_import
import 'package:flutter/foundation.dart';

part 'generated/scheduled_match.freezed.dart';
part 'generated/scheduled_match.g.dart';

typedef BlockMap = Map<SingleRelation<Player>, PlayerBlock>;

@freezed
class ScheduledMatch extends Model with _$ScheduledMatch {
  const ScheduledMatch._();

  const factory ScheduledMatch({
    required String id,
    required DateTime created,
    required DateTime updated,
    @SingleRelationMatchDataConverter()
    @JsonKey(name: 'match')
    required SingleRelation<MatchData> matchRel,
    required ScheduleStatus status,
    @_BlockingPlayersConverter()
    @JsonKey(name: 'blockingPlayers')
    required BlockMap blockingPlayersRel,
  }) = _ScheduledMatch;

  Map<Player, PlayerBlock> get blockingPlayers {
    return blockingPlayersRel.map(
      (playerRel, playerBlock) => MapEntry(playerRel.model!, playerBlock),
    );
  }

  factory ScheduledMatch.fromJson(Map<String, dynamic> json) =>
      _$ScheduledMatchFromJson(json);
}

class _BlockingPlayersConverter
    implements JsonConverter<BlockMap, Map<String, dynamic>> {
  const _BlockingPlayersConverter();

  @override
  BlockMap fromJson(Map<String, dynamic> json) {
    var blockingPlayers = json.map(
      (playerId, playerBlockJson) {
        var playerRel = SingleRelation<Player>(relationId: playerId);
        var playerBlockMap = Map<String, dynamic>.from(playerBlockJson as Map);
        var playerBlock = PlayerBlock.fromJson(playerBlockMap);
        return MapEntry(playerRel, playerBlock);
      },
    );
    return blockingPlayers;
  }

  @override
  Map<String, dynamic> toJson(BlockMap object) {
    throw UnimplementedError();
  }
}

enum ScheduleStatus {
  @JsonValue(0)
  done,
  @JsonValue(1)
  inProgress,
  @JsonValue(2)
  ready,
  @JsonValue(3)
  courtWait,
  @JsonValue(4)
  playerRest,
  @JsonValue(5)
  playerWait,
  @JsonValue(6)
  wait,
}
