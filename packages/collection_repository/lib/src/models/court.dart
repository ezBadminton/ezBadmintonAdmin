import 'package:collection_repository/collection_repository.dart';
import 'package:collection_repository/src/models/model_converter.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
// ignore: unused_import
import 'package:flutter/foundation.dart';

part 'generated/court.freezed.dart';
part 'generated/court.g.dart';

@freezed
class Court extends Model with _$Court {
  const Court._();

  /// A badminton court with a specified [location] usually the hall where it
  /// is and a [name].
  ///
  /// The [positionX], [positionY] and [rotation] are for saving the court's
  /// position on the drag and drop interface for mapping the courts of a hall.
  const factory Court({
    required String id,
    required DateTime created,
    required DateTime updated,
    required Location location,
    required String name,
    required int positionX,
    required int positionY,
    required double rotation,
  }) = _Court;

  factory Court.fromJson(Map<String, dynamic> json) =>
      _$CourtFromJson(ModelConverter.convertExpansions(json, expandedFields));

  static const List<ExpandedField> expandedFields = [
    ExpandedField(
      model: Location,
      key: 'location',
      isRequired: true,
      isSingle: true,
    ),
  ];

  @override
  Map<String, dynamic> toCollapsedJson() {
    Map<String, dynamic> json = toJson();
    return ModelConverter.collapseExpansions(json, expandedFields);
  }
}
