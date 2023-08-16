import 'package:collection_repository/collection_repository.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
// ignore: unused_import
import 'package:flutter/foundation.dart';

part 'generated/gymnasium.freezed.dart';
part 'generated/gymnasium.g.dart';

@freezed
class Gymnasium extends Model with _$Gymnasium {
  const Gymnasium._();

  /// A gymnasium where the tournament is hosted containing [Court]s
  /// in a grid of [rows] and [columns].
  ///
  /// The identifying [name] and the [directions] help players find the venue.
  const factory Gymnasium({
    required String id,
    required DateTime created,
    required DateTime updated,
    required String name,
    String? directions,
    required int rows,
    required int columns,
  }) = _Gymnasium;

  factory Gymnasium.fromJson(Map<String, dynamic> json) =>
      _$GymnasiumFromJson(json);

  factory Gymnasium.newGymnasium() => Gymnasium(
        id: '',
        created: DateTime.now(),
        updated: DateTime.now(),
        name: '',
        directions: '',
        rows: defaultGridSize,
        columns: defaultGridSize,
      );

  @override
  Map<String, dynamic> toCollapsedJson() {
    return toJson();
  }

  static const int defaultGridSize = 2;
}
