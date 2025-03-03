import 'package:model_repository/model_repository.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
// ignore: unused_import
import 'package:flutter/foundation.dart';
import 'package:model_repository/src/relations.dart';

part 'generated/player.freezed.dart';
part 'generated/player.g.dart';

@freezed
class Player extends Model with _$Player {
  const Player._();

  /// A player in a badminton tournament.
  const factory Player({
    required String id,
    required DateTime created,
    required DateTime updated,
    required String firstName,
    required String lastName,
    String? notes,
    @SingleRelationClubConverter()
    @JsonKey(name: 'club')
    required SingleRelation<Club> clubRel,
    required PlayerStatus status,
  }) = _Player;

  Club? get club => clubRel.model;

  factory Player.fromJson(Map<String, dynamic> json) => _$PlayerFromJson(json);

  // This object is used as the original whenever a new player is added.
  factory Player.newPlayer() => Player(
        id: '',
        created: DateTime.now().toUtc(),
        updated: DateTime.now().toUtc(),
        firstName: '',
        lastName: '',
        clubRel: SingleRelation(),
        status: PlayerStatus.notAttending,
      );
}

enum Gender { female, male, none }

enum PlayerStatus { notAttending, attending, injured, forfeited, disqualified }
