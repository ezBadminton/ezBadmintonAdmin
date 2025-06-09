import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:model_repository/model_repository.dart';
// ignore: unused_import
import 'package:flutter/foundation.dart';

part 'generated/infoscreen_user.freezed.dart';
part 'generated/infoscreen_user.g.dart';

@freezed
class InfoscreenUser extends Model with _$InfoscreenUser {
  const InfoscreenUser._();

  const factory InfoscreenUser({
    required String id,
    required DateTime created,
    required DateTime updated,
    required String username,
    required String initToken,
  }) = _InfoscreenUser;

  factory InfoscreenUser.fromJson(Map<String, dynamic> json) =>
      _$InfoscreenUserFromJson(json);
}
