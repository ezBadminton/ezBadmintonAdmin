import 'package:collection_repository/collection_repository.dart';
import 'package:collection_repository/src/models/model_converter.dart';
import 'package:const_date_time/const_date_time.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
// ignore: unused_import
import 'package:flutter/foundation.dart';

part 'generated/player.freezed.dart';
part 'generated/player.g.dart';

@freezed
class Player extends Model with _$Player {
  const Player._();

  /// A player in a badminton tournament.
  ///
  /// The admin app uses the optional personal data of [gender], [dateOfBirth]
  /// and [playingLevel] avoid registering players into competitions where they
  /// should not compete.
  const factory Player({
    required String id,
    required DateTime created,
    required DateTime updated,
    required String firstName,
    required String lastName,
    Gender? gender,
    DateTime? dateOfBirth,
    @Default('') String eMail,
    @Default(Club.clubless) Club club,
    @Default(PlayingLevel.unrated) PlayingLevel playingLevel,
  }) = _Player;

  factory Player.fromJson(Map<String, dynamic> json) =>
      _$PlayerFromJson(ModelConverter.convertExpansions(json, expandedFields));

  // This object is used as the original whenever a new player is added.
  static const Player newPlayer = Player(
    id: '',
    created: ConstDateTime(0),
    updated: ConstDateTime(0),
    firstName: '',
    lastName: '',
  );

  static const List<ExpandedField> expandedFields = [
    ExpandedField(
      model: Club,
      key: 'club',
      isRequired: false,
      isSingle: true,
    ),
    ExpandedField(
      model: PlayingLevel,
      key: 'playingLevel',
      isRequired: false,
      isSingle: true,
    ),
  ];

  @override
  Map<String, dynamic> toCollapsedJson() {
    Map<String, dynamic> json = this.toJson();
    return ModelConverter.collapseExpansions(json, expandedFields);
  }

  int calculateAge() {
    if (dateOfBirth == null) {
      return -1;
    }
    var now = DateTime.now();
    int age = now.year - dateOfBirth!.year;
    if (now.month <= dateOfBirth!.month && now.day < dateOfBirth!.day) {
      age--;
    }
    return age;
  }
}

enum Gender { female, male, none }
