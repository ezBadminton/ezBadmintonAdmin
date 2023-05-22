import 'package:collection_repository/collection_repository.dart';
import 'package:collection_repository/src/models/model_converter.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'generated/competition.freezed.dart';
part 'generated/competition.g.dart';

@freezed
class Competition extends Model with _$Competition {
  const Competition._();

  /// A competition within a badminton tournament.
  ///
  /// Competitions are categorized by [teamSize] (singles, or doubles),
  /// [gender], [age] and playing level ([minLevel],[maxLevel]). The competiton
  /// also holds all partipating Teams as [registrations].
  const factory Competition({
    required String id,
    required DateTime created,
    required DateTime updated,
    required int teamSize,
    required GenderCategory gender,
    AgeRestriction? ageRestriction,
    int? age,
    PlayingLevel? minLevel,
    PlayingLevel? maxLevel,
    required List<Team> registrations,
  }) = _Competition;

  factory Competition.fromJson(Map<String, dynamic> json) =>
      _$CompetitionFromJson(
          ModelConverter.convertExpansions(json, expandedFields));

  /// Method for discering a Competition into the basic competition types
  /// of doubles, mixed or singles. If none of these are applicable it returns
  /// `CompetitionType.other`.
  CompetitionType getCompetitionType() {
    if (teamSize == 1) {
      return CompetitionType.singles;
    } else if (teamSize == 2 && gender != GenderCategory.any) {
      return gender == GenderCategory.mixed
          ? CompetitionType.mixed
          : CompetitionType.doubles;
    } else {
      return CompetitionType.other;
    }
  }

  static const List<ExpandedField> expandedFields = [
    ExpandedField(
      model: PlayingLevel,
      key: 'minLevel',
      isRequired: false,
      isSingle: true,
    ),
    ExpandedField(
      model: PlayingLevel,
      key: 'maxLevel',
      isRequired: false,
      isSingle: true,
    ),
    ExpandedField(
      model: Team,
      key: 'registrations',
      isRequired: true,
      isSingle: false,
    ),
  ];

  @override
  Map<String, dynamic> toCollapsedJson() {
    Map<String, dynamic> json = this.toJson();
    return ModelConverter.collapseExpansions(json, expandedFields);
  }
}

enum GenderCategory { female, male, mixed, any }

enum AgeRestriction { under, over }

enum CompetitionType { doubles, singles, mixed, other }
