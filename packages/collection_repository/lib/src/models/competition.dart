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
  /// [genderCategory], [ageGroups] and [playingLevels].
  /// The competiton also holds all partipating Teams as [registrations].
  const factory Competition({
    required String id,
    required DateTime created,
    required DateTime updated,
    required int teamSize,
    required GenderCategory genderCategory,
    required List<AgeGroup> ageGroups,
    required List<PlayingLevel> playingLevels,
    required List<Team> registrations,
  }) = _Competition;

  factory Competition.fromJson(Map<String, dynamic> json) =>
      _$CompetitionFromJson(
          ModelConverter.convertExpansions(json, expandedFields));

  factory Competition.newCompetition({
    required int teamSize,
    required GenderCategory genderCategory,
    List<AgeGroup> ageGroups = const [],
    List<PlayingLevel> playingLevels = const [],
    List<Team> registrations = const [],
  }) {
    return Competition(
      id: '',
      created: DateTime.now(),
      updated: DateTime.now(),
      teamSize: teamSize,
      genderCategory: genderCategory,
      ageGroups: ageGroups,
      playingLevels: playingLevels,
      registrations: registrations,
    );
  }

  /// Basic competition type of doubles, mixed or singles.
  ///
  /// If none of these are applicable it returns `CompetitionType.other`.
  CompetitionType get type {
    if (teamSize == 1) {
      return CompetitionType.singles;
    } else if (teamSize == 2 && genderCategory != GenderCategory.any) {
      return genderCategory == GenderCategory.mixed
          ? CompetitionType.mixed
          : CompetitionType.doubles;
    } else {
      return CompetitionType.other;
    }
  }

  static const List<ExpandedField> expandedFields = [
    ExpandedField(
      model: AgeGroup,
      key: 'ageGroups',
      isRequired: true,
      isSingle: false,
    ),
    ExpandedField(
      model: PlayingLevel,
      key: 'playingLevels',
      isRequired: true,
      isSingle: false,
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

enum CompetitionType { doubles, singles, mixed, other }
