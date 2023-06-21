import 'package:collection_repository/src/models/models.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'generated/tournament.freezed.dart';
part 'generated/tournament.g.dart';

@freezed
class Tournament extends Model with _$Tournament {
  const Tournament._();

  /// The [Tournament] currently being administrated.
  ///
  /// On first start, the admin app mandates the creation of a tournament by
  /// asking for a [title]. From then the `tournaments` collection only
  /// contains one [Tournament] object. The tournament can be further configured
  /// afterwards.
  ///
  /// [useAgeGroups] states if the [Competition]s in the tournament are
  /// categorized by [AgeGroup]s.
  /// Analog for [usePlayingLevels] and [PlayingLevel]s.
  factory Tournament({
    required String id,
    required DateTime created,
    required DateTime updated,
    required String title,
    required bool useAgeGroups,
    required bool usePlayingLevels,
  }) = _Tournament;

  factory Tournament.fromJson(Map<String, dynamic> json) =>
      _$TournamentFromJson(json);

  @override
  Map<String, dynamic> toCollapsedJson() {
    return toJson();
  }
}
