import 'package:freezed_annotation/freezed_annotation.dart';

class NullableDateTimeConverter implements JsonConverter<DateTime?, String?> {
  const NullableDateTimeConverter();

  @override
  DateTime? fromJson(String? json) {
    if (json == null || json == "") {
      return null;
    }
    return DateTime.parse(json);
  }

  @override
  String? toJson(DateTime? dateTime) {
    return dateTime?.toIso8601String();
  }
}
