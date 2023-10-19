import 'package:collection_repository/collection_repository.dart';
import 'package:collection_repository/src/expansion_tree/expanded_field.dart';
import 'package:collection_repository/src/utils/model_converter.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
// ignore: unused_import
import 'package:flutter/foundation.dart';

part 'generated/court.freezed.dart';
part 'generated/court.g.dart';

@freezed
class Court extends Model with _$Court {
  const Court._();

  /// A badminton court with a specified [gymnasium] where it is located
  /// and a [name].
  ///
  /// The [positionX], [positionY] are for saving the court's
  /// position in the rows and columns of courts in the gymnasium.
  ///
  /// When the court [isActive], matches can be scheduled on it.
  const factory Court({
    required String id,
    required DateTime created,
    required DateTime updated,
    required Gymnasium gymnasium,
    required String name,
    required int positionX,
    required int positionY,
    required bool isActive,
  }) = _Court;

  factory Court.fromJson(Map<String, dynamic> json) =>
      _$CourtFromJson(json..cleanUpExpansions(expandedFields));

  factory Court.newCourt({
    required String name,
    required Gymnasium gymnasium,
    required int x,
    required int y,
  }) =>
      Court(
        id: '',
        created: DateTime.now().toUtc(),
        updated: DateTime.now().toUtc(),
        gymnasium: gymnasium,
        name: name,
        positionX: x,
        positionY: y,
        isActive: true,
      );

  static const List<ExpandedField> expandedFields = [
    ExpandedField(
      model: Gymnasium,
      key: 'gymnasium',
      isRequired: true,
      isSingle: true,
    ),
  ];

  @override
  Map<String, dynamic> toCollapsedJson() {
    Map<String, dynamic> json = toJson();
    return json..collapseExpansions(expandedFields);
  }
}
