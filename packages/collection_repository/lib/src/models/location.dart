import 'package:collection_repository/collection_repository.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
// ignore: unused_import
import 'package:flutter/foundation.dart';

part 'generated/location.freezed.dart';
part 'generated/location.g.dart';

@freezed
class Location extends Model with _$Location {
  const Location._();
  const factory Location({
    required String id,
    required DateTime created,
    required DateTime updated,
    required String name,
    required String directions,
  }) = _Location;

  factory Location.fromJson(Map<String, dynamic> json) =>
      _$LocationFromJson(json);

  @override
  Map<String, dynamic> toCollapsedJson() {
    return this.toJson();
  }
}
