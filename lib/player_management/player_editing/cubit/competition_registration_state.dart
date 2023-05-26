import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/input_models/no_validation.dart';
import 'package:ez_badminton_admin_app/input_models/selection.dart';
import 'package:formz/formz.dart';

class CompetitionRegistrationState with FormzMixin {
  CompetitionRegistrationState({
    this.formStep = 0,
    this.competition,
    this.competitionType = const SelectionInput.dirty(value: null),
    this.genderCategory = const SelectionInput.dirty(
      emptyAllowed: true,
      value: null,
    ),
    this.ageGroup = const SelectionInput.dirty(
      emptyAllowed: true,
      value: null,
    ),
    this.playingLevel =
        const SelectionInput.dirty(emptyAllowed: true, value: null),
    this.partnerName = const NoValidationInput.dirty(''),
  });

  final int formStep;
  final Competition? competition;
  final SelectionInput<CompetitionType> competitionType;
  final SelectionInput<GenderCategory> genderCategory;
  final SelectionInput<AgeGroup> ageGroup;
  final SelectionInput<PlayingLevel> playingLevel;
  final NoValidationInput partnerName;

  CompetitionRegistrationState copyWith({
    int? formStep,
    Competition competition = const _NullCompetition(),
    SelectionInput<CompetitionType>? competitionType,
    SelectionInput<GenderCategory>? genderCategory,
    SelectionInput<AgeGroup>? ageGroup,
    SelectionInput<PlayingLevel>? playingLevel,
    NoValidationInput? partnerName,
  }) =>
      CompetitionRegistrationState(
        formStep: formStep ?? this.formStep,
        competition:
            competition is _NullCompetition ? this.competition : competition,
        competitionType: competitionType ?? this.competitionType,
        genderCategory: genderCategory ?? this.genderCategory,
        partnerName: partnerName ?? this.partnerName,
        ageGroup: ageGroup ?? this.ageGroup,
        playingLevel: playingLevel ?? this.playingLevel,
      );

  CompetitionRegistrationState copyWithCompetitionParameter<P>(
    P? parameter,
  ) {
    switch (P) {
      case PlayingLevel:
        return copyWith(
          playingLevel: SelectionInput.dirty(
            emptyAllowed: true,
            value: parameter as PlayingLevel?,
          ),
        );
      case AgeGroup:
        return copyWith(
          ageGroup: SelectionInput.dirty(
            emptyAllowed: true,
            value: parameter as AgeGroup?,
          ),
        );
      case GenderCategory:
        return copyWith(
          genderCategory: SelectionInput.dirty(
            emptyAllowed: true,
            value: parameter as GenderCategory?,
          ),
        );
      case CompetitionType:
        return copyWith(
          competitionType: SelectionInput.dirty(
            emptyAllowed: true,
            value: parameter as CompetitionType?,
          ),
        );
      default:
        assert(false, 'Unknown competition parameter type');
        return this;
    }
  }

  P? getCompetitionParameter<P>() {
    return inputs.whereType<FormzInput<P?, Object>>().first.value;
  }

  @override
  List<FormzInput> get inputs =>
      [playingLevel, ageGroup, genderCategory, competitionType, partnerName];
}

class _NullCompetition implements Competition {
  const _NullCompetition();
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
