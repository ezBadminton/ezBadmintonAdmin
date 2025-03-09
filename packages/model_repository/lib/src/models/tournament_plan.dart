import 'package:model_repository/model_repository.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'generated/tournament_plan.freezed.dart';
part 'generated/tournament_plan.g.dart';

@Freezed(toJson: false, fromJson: true)
sealed class TournamentPlan extends Model with _$TournamentPlan {
  const TournamentPlan._();

  const factory TournamentPlan({
    required String id,
    required DateTime created,
    required DateTime updated,
    @JsonKey(name: 'competition')
    required SingleRelation<Competition> competitionRel,
    required bool started,
    required bool ended,
    required Tournament tournament,
  }) = _TournamentPlan;

  Competition get competition => competitionRel.model!;

  factory TournamentPlan.fromJson(Map<String, dynamic> json) =>
      _$TournamentPlanFromJson(json);

  @override
  Map<String, dynamic> toJson() => throw UnimplementedError();
}
