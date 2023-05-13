import 'package:collection_repository/collection_repository.dart';
import 'package:collection_repository/src/models/model_converter.dart';
import 'package:const_date_time/const_date_time.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'generated/competition.freezed.dart';
part 'generated/competition.g.dart';

@freezed
class Competition extends Model with _$Competition {
  const Competition._();
  const factory Competition({
    required String id,
    required DateTime created,
    required DateTime updated,
    required int teamSize,
    required GenderCategory gender,
    required AgeRestriction ageRestriction,
    @Default(0) int age,
    required PlayingLevel minLevel,
    required PlayingLevel maxLevel,
    required List<Team> registrations,
  }) = _Competition;

  static const Competition singles = Competition(
    id: 'singles',
    created: ConstDateTime(0),
    updated: ConstDateTime(0),
    teamSize: 1,
    gender: GenderCategory.any,
    ageRestriction: AgeRestriction.none,
    minLevel: PlayingLevel.unrated,
    maxLevel: PlayingLevel.unrated,
    registrations: const [],
  );

  static const Competition doubles = Competition(
    id: 'doubles',
    created: ConstDateTime(0),
    updated: ConstDateTime(0),
    teamSize: 2,
    gender: GenderCategory.any,
    ageRestriction: AgeRestriction.none,
    minLevel: PlayingLevel.unrated,
    maxLevel: PlayingLevel.unrated,
    registrations: const [],
  );

  static const Competition mixed = Competition(
    id: 'mixed',
    created: ConstDateTime(0),
    updated: ConstDateTime(0),
    teamSize: 2,
    gender: GenderCategory.mixed,
    ageRestriction: AgeRestriction.none,
    minLevel: PlayingLevel.unrated,
    maxLevel: PlayingLevel.unrated,
    registrations: const [],
  );

  static const Competition other = Competition(
    id: 'other',
    created: ConstDateTime(0),
    updated: ConstDateTime(0),
    teamSize: 999,
    gender: GenderCategory.any,
    ageRestriction: AgeRestriction.none,
    minLevel: PlayingLevel.unrated,
    maxLevel: PlayingLevel.unrated,
    registrations: const [],
  );

  factory Competition.fromJson(Map<String, dynamic> json) =>
      _$CompetitionFromJson(
          ModelConverter.convertExpansions(json, expandedFields));

  Competition getCompetitionType() {
    if (teamSize == 1) {
      return Competition.singles;
    } else if (teamSize == 2 && gender != GenderCategory.any) {
      return gender == GenderCategory.mixed
          ? Competition.mixed
          : Competition.doubles;
    } else {
      return Competition.other;
    }
  }

  static const List<ExpandedField> expandedFields = [
    ExpandedField(
      model: PlayingLevel,
      key: 'minLevel',
      isRequired: true,
      isSingle: true,
    ),
    ExpandedField(
      model: PlayingLevel,
      key: 'maxLevel',
      isRequired: true,
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

enum AgeRestriction { under, over, none }
