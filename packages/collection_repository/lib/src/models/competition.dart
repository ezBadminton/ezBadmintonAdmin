import 'dart:math';

import 'package:collection_repository/collection_repository.dart';
import 'package:collection_repository/src/expansion_tree/expanded_field.dart';
import 'package:collection_repository/src/models/tournament_mode_settings.dart';
import 'package:collection_repository/src/utils/model_converter.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'generated/competition.freezed.dart';
part 'generated/competition.g.dart';

@freezed
class Competition extends Model with _$Competition {
  const Competition._();

  /// A competition within a badminton tournament.
  ///
  /// Competitions are categorized by [teamSize] (singles, or doubles),
  /// [genderCategory], [ageGroup] and [playingLevel].
  /// The competiton also holds all partipating Teams as [registrations].
  const factory Competition({
    required String id,
    required DateTime created,
    required DateTime updated,
    required int teamSize,
    required GenderCategory genderCategory,
    AgeGroup? ageGroup,
    PlayingLevel? playingLevel,
    required List<Team> registrations,
    TournamentModeSettings? tournamentModeSettings,
    required List<Team> seeds,
    required int rngSeed,
  }) = _Competition;

  factory Competition.fromJson(Map<String, dynamic> json) =>
      _$CompetitionFromJson(json..cleanUpExpansions(expandedFields));

  factory Competition.newCompetition({
    required int teamSize,
    required GenderCategory genderCategory,
    AgeGroup? ageGroup,
    PlayingLevel? playingLevel,
    List<Team> registrations = const [],
  }) {
    return Competition(
      id: '',
      created: DateTime.now(),
      updated: DateTime.now(),
      teamSize: teamSize,
      genderCategory: genderCategory,
      ageGroup: ageGroup,
      playingLevel: playingLevel,
      registrations: registrations,
      seeds: const [],
      rngSeed: Random().nextInt(1 << 32),
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
      key: 'ageGroup',
      isRequired: false,
      isSingle: true,
    ),
    ExpandedField(
      model: PlayingLevel,
      key: 'playingLevel',
      isRequired: false,
      isSingle: true,
    ),
    ExpandedField(
      model: Team,
      key: 'registrations',
      isRequired: true,
      isSingle: false,
    ),
    ExpandedField(
      model: TournamentModeSettings,
      key: 'tournamentModeSettings',
      isRequired: false,
      isSingle: true,
    ),
    ExpandedField(
      model: Team,
      key: 'seeds',
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

enum GenderCategory { female, male, mixed, any }

enum CompetitionType { doubles, singles, mixed, other }
