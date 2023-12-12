import 'package:collection_repository/collection_repository.dart';
import 'package:collection_repository/src/expansion_tree/expanded_field.dart';
import 'package:collection_repository/src/utils/model_converter.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'generated/tie_breaker.freezed.dart';
part 'generated/tie_breaker.g.dart';

@freezed
class TieBreaker extends Model with _$TieBreaker {
  const TieBreaker._();

  const factory TieBreaker({
    required String id,
    required DateTime created,
    required DateTime updated,
    required List<Team> tieBreakerRanking,
  }) = _TieBreaker;

  factory TieBreaker.fromJson(Map<String, dynamic> json) =>
      _$TieBreakerFromJson(json..cleanUpExpansions(expandedFields));

  static const List<ExpandedField> expandedFields = [
    ExpandedField(
      model: Team,
      key: 'tieBreakerRanking',
      isRequired: true,
      isSingle: false,
    ),
  ];

  @override
  Map<String, dynamic> toCollapsedJson() {
    Map<String, dynamic> json = toJson();
    return json..collapseExpansions(expandedFields);
  }
}
