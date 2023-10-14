import 'package:collection_repository/src/expansion_tree/expanded_field.dart';
import 'package:collection_repository/src/utils/model_converter.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:collection_repository/collection_repository.dart';
// ignore: unused_import
import 'package:flutter/foundation.dart';

part 'generated/match.freezed.dart';
part 'generated/match.g.dart';

@freezed
class Match extends Model with _$Match {
  const Match._();

  /// A badminton match in a [Competition].
  ///
  /// The match is assigned to a [court]. The [status] of the Match dictates the
  /// administrative stage it is in. The [sets] of the match is stored as a List
  /// of [MatchSet]s. If one of the players decides to upload a photo of the
  /// handwritten [resultCard] via the app its filepath is included here.
  /// This would save a walk to the tournament admin desk.
  ///
  /// The [Match] class can exist without explicitly naming the opponent [Team]s
  /// because those are functionally dependent on the [Competition]s draw
  /// (which is just a List of [Team]s), its tournament mode settings
  /// and on the match results. Since those three inputs are stored they can
  /// always be used to reconstruct who is playing in a particular [Match].
  /// This reconstruction can also be referred to as "hydrating" the tournament
  /// mode. This way a match can also be assigned to a court before the
  /// opponents are even determined. For example the final can be put on
  /// center court while the semi-finals are still ongoing.
  const factory Match({
    required String id,
    required DateTime created,
    required DateTime updated,
    required List<MatchSet> sets,
    Court? court,
    required MatchStatus status,
    String? resultCard,
  }) = _Match;

  factory Match.fromJson(Map<String, dynamic> json) =>
      _$MatchFromJson(json..cleanUpExpansions(expandedFields));

  factory Match.newMatch() => Match(
        id: '',
        created: DateTime.now(),
        updated: DateTime.now(),
        sets: const [],
        status: MatchStatus.planned,
      );

  static const List<ExpandedField> expandedFields = [
    ExpandedField(
      model: MatchSet,
      key: 'sets',
      isRequired: true,
      isSingle: false,
    ),
    ExpandedField(
      model: Court,
      key: 'court',
      isRequired: false,
      isSingle: true,
    ),
  ];

  @override
  Map<String, dynamic> toCollapsedJson() {
    Map<String, dynamic> json = toJson();
    return json..collapseExpansions(expandedFields);
  }
}

enum MatchStatus {
  planned,
  calledOut,
  inProgress,
  cancelled,
  finished,
  walkover,
}
