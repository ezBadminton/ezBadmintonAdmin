import 'dart:math';

import 'package:model_repository/model_repository.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:model_repository/src/relations.dart';

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
    @JsonKey(name: 'ageGroup')
    required SingleRelation<AgeGroup> ageGroupRel,
    @JsonKey(name: 'playingLevel')
    required SingleRelation<PlayingLevel> playingLevelRel,
    @JsonKey(name: 'registrations')
    required MultiRelation<Team> registrationsRel,
    @JsonKey(name: 'tournamentModeSettings')
    required SingleRelation<TournamentModeSettings> tournamentModeSettingsRel,
    @JsonKey(name: 'seeds')
    required MultiRelation<Team> seedsRel,
    @JsonKey(name: 'draw')
    required MultiRelation<Team> drawRel,
    @JsonKey(name: 'matches')
    required MultiRelation<MatchData> matchesRel,
    @JsonKey(name: 'tieBreakers')
    required MultiRelation<TieBreaker> tieBreakersRel,
    required int rngSeed,
  }) = _Competition;

  AgeGroup? get ageGroup => ageGroupRel.model;
  PlayingLevel? get playingLevel => playingLevelRel.model;
  List<Team> get registrations => registrationsRel.models;
  TournamentModeSettings? get tournamentModeSettings =>
      tournamentModeSettingsRel.model;
  List<Team> get seeds => seedsRel.models;
  List<Team> get draw => drawRel.models;
  List<MatchData> get matches => matchesRel.models;
  List<TieBreaker> get tieBreakers => tieBreakersRel.models;

  factory Competition.fromJson(Map<String, dynamic> json) =>
      _$CompetitionFromJson(json);

  factory Competition.newCompetition({
    required int teamSize,
    required GenderCategory genderCategory,
    AgeGroup? ageGroup,
    PlayingLevel? playingLevel,
    List<Team> registrations = const [],
  }) {
    return Competition(
      id: '',
      created: DateTime.now().toUtc(),
      updated: DateTime.now().toUtc(),
      teamSize: teamSize,
      genderCategory: genderCategory,
      ageGroupRel: SingleRelation.fromModel(ageGroup),
      playingLevelRel: SingleRelation.fromModel(playingLevel),
      registrationsRel: MultiRelation.fromModels(registrations),
      tournamentModeSettingsRel: SingleRelation(),
      seedsRel: MultiRelation(),
      drawRel: MultiRelation(),
      matchesRel: MultiRelation(),
      tieBreakersRel: MultiRelation(),
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
}

enum GenderCategory { female, male, mixed, any }

enum CompetitionType { doubles, singles, mixed, other }
