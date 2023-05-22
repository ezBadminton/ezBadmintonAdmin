import 'package:collection_repository/collection_repository.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
// ignore: unused_import
import 'package:flutter/foundation.dart';

part 'generated/club.freezed.dart';
part 'generated/club.g.dart';

@freezed
class Club extends Model with _$Club {
  const Club._();

  /// Badminton club that a Player can be part of
  const factory Club({
    required String id,
    required DateTime created,
    required DateTime updated,

    /// Name of the club
    required String name,
  }) = _Club;

  factory Club.newClub({required String name}) => Club(
        id: '',
        created: DateTime.now(),
        updated: DateTime.now(),
        name: name,
      );

  factory Club.fromJson(Map<String, dynamic> json) => _$ClubFromJson(json);

  @override
  Map<String, dynamic> toCollapsedJson() {
    return this.toJson();
  }
}
