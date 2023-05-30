import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/collection_queries/collection_querier.dart';
import 'package:ez_badminton_admin_app/input_models/no_validation.dart';
import 'package:ez_badminton_admin_app/input_models/selection.dart';
import 'package:ez_badminton_admin_app/widgets/loading_screen/loading_screen.dart';
import 'package:formz/formz.dart';

class CompetitionRegistrationState extends CollectionFetcherState
    with FormzMixin, CollectionGetter {
  CompetitionRegistrationState({
    this.collections = const {},
    this.loadingStatus = LoadingStatus.loading,
    this.formStep = 0,
    this.competition = const SelectionInput.dirty(value: null),
    this.partner = const SelectionInput.dirty(emptyAllowed: true, value: null),
    this.competitionType = const SelectionInput.dirty(value: null),
    this.genderCategory = const SelectionInput.dirty(value: null),
    this.ageGroup = const SelectionInput.dirty(
      emptyAllowed: true,
      value: null,
    ),
    this.playingLevel =
        const SelectionInput.dirty(emptyAllowed: true, value: null),
    this.partnerName = const NoValidationInput.dirty(''),
  });

  @override
  final Map<Type, List<Model>> collections;
  final LoadingStatus loadingStatus;

  final int formStep;
  final SelectionInput<Competition> competition;
  final SelectionInput<Player> partner;
  final SelectionInput<CompetitionType> competitionType;
  final SelectionInput<GenderCategory> genderCategory;
  final SelectionInput<AgeGroup> ageGroup;
  final SelectionInput<PlayingLevel> playingLevel;
  final NoValidationInput partnerName;

  CompetitionRegistrationState copyWith({
    Map<Type, List<Model>>? collections,
    LoadingStatus? loadingStatus,
    int? formStep,
    SelectionInput<Competition>? competition,
    SelectionInput<Player>? partner,
    SelectionInput<CompetitionType>? competitionType,
    SelectionInput<GenderCategory>? genderCategory,
    SelectionInput<AgeGroup>? ageGroup,
    SelectionInput<PlayingLevel>? playingLevel,
    NoValidationInput? partnerName,
  }) =>
      CompetitionRegistrationState(
        collections: collections ?? this.collections,
        loadingStatus: loadingStatus ?? this.loadingStatus,
        formStep: formStep ?? this.formStep,
        competition: competition ?? this.competition,
        partner: partner ?? this.partner,
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
            value: parameter as GenderCategory?,
          ),
        );
      case CompetitionType:
        return copyWith(
          competitionType: SelectionInput.dirty(
            value: parameter as CompetitionType?,
          ),
        );
      default:
        assert(false, 'Unknown competition parameter type');
        return this;
    }
  }

  @override
  CompetitionRegistrationState copyWithCollection({
    required Type modelType,
    required List<Model> collection,
  }) {
    var newCollections = Map.of(collections);
    newCollections.remove(modelType);
    newCollections.putIfAbsent(modelType, () => collection);
    return copyWith(collections: Map.unmodifiable(newCollections));
  }

  P? getCompetitionParameter<P>() {
    return inputs.whereType<FormzInput<P?, Object>>().first.value;
  }

  @override
  List<FormzInput> get inputs =>
      [playingLevel, ageGroup, genderCategory, competitionType, partnerName];
}
