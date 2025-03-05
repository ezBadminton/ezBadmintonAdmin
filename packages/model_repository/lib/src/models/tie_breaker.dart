import 'package:model_repository/model_repository.dart';
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
    @JsonKey(name: 'tieBreakerRanking')
    required MultiRelation<Team> tieBreakerRankingRel,
  }) = _TieBreaker;

  List<Team> get tieBreakerRanking => tieBreakerRankingRel.models;

  factory TieBreaker.fromJson(Map<String, dynamic> json) =>
      _$TieBreakerFromJson(json);

  factory TieBreaker.newTiebreaker(List<Team> tieBreakerRanking) => TieBreaker(
        id: '',
        created: DateTime.now().toUtc(),
        updated: DateTime.now().toUtc(),
        tieBreakerRankingRel: MultiRelation.fromModels(tieBreakerRanking),
      );
}
