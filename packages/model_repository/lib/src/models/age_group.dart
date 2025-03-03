import 'package:model_repository/model_repository.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
// ignore: unused_import
import 'package:flutter/foundation.dart';

part 'generated/age_group.freezed.dart';
part 'generated/age_group.g.dart';

@freezed
class AgeGroup extends Model with _$AgeGroup {
  const AgeGroup._();
  factory AgeGroup({
    required String id,
    required DateTime created,
    required DateTime updated,
    required int age,
    required AgeGroupType type,
  }) = _AgeGroup;

  factory AgeGroup.fromJson(Map<String, dynamic> json) =>
      _$AgeGroupFromJson(json);

  factory AgeGroup.newAgeGroup({
    required AgeGroupType type,
    required int age,
  }) =>
      AgeGroup(
        id: '',
        created: DateTime.now().toUtc(),
        updated: DateTime.now().toUtc(),
        age: age,
        type: type,
      );
}

enum AgeGroupType { over, under }
