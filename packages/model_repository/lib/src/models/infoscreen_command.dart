import 'dart:ui';

import 'package:freezed_annotation/freezed_annotation.dart';

part 'generated/infoscreen_command.freezed.dart';
part 'generated/infoscreen_command.g.dart';

@Freezed(toJson: false)
class InfoscreenCommand with _$InfoscreenCommand {
  const factory InfoscreenCommand({
    @Default(Offset.zero)
    @JsonKey(
      fromJson: InfoscreenCommand._panFromJson,
    )
    Offset pan,
    @JsonKey(defaultValue: false) required bool zoomIn,
    @JsonKey(defaultValue: false) required bool zoomOut,
    @JsonKey(defaultValue: false) required bool reset,
  }) = _InfoScreen;

  factory InfoscreenCommand.fromJson(Map<String, dynamic> json) =>
      _$InfoscreenCommandFromJson(json);

  static Offset _panFromJson(Map<String, dynamic> json) {
    double x = json["x"].toDouble();
    double y = json["y"].toDouble();
    return Offset(x, y);
  }
}
