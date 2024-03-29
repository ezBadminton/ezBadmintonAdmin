import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/collection_queries/collection_querier.dart';
import 'package:ez_badminton_admin_app/input_models/selection.dart';
import 'package:ez_badminton_admin_app/widgets/dialog_listener/cubit_mixin/dialog_cubit.dart';
import 'package:ez_badminton_admin_app/widgets/loading_screen/loading_screen.dart';
import 'package:formz/formz.dart';

class CompetitionRegistrationState extends CollectionQuerierState
    implements DialogState {
  CompetitionRegistrationState({
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
    this.dialog = const CubitDialog(),
    this.collections = const [],
  });

  @override
  final LoadingStatus loadingStatus;

  final int formStep;
  final SelectionInput<Competition> competition;
  final SelectionInput<Player> partner;
  final SelectionInput<CompetitionType> competitionType;
  final SelectionInput<GenderCategory> genderCategory;
  final SelectionInput<AgeGroup> ageGroup;
  final SelectionInput<PlayingLevel> playingLevel;

  @override
  final CubitDialog dialog;

  @override
  final List<List<Model>> collections;

  CompetitionRegistrationState copyWith({
    LoadingStatus? loadingStatus,
    int? formStep,
    SelectionInput<Competition>? competition,
    SelectionInput<Player>? partner,
    SelectionInput<CompetitionType>? competitionType,
    SelectionInput<GenderCategory>? genderCategory,
    SelectionInput<AgeGroup>? ageGroup,
    SelectionInput<PlayingLevel>? playingLevel,
    CubitDialog? dialog,
    List<List<Model>>? collections,
  }) =>
      CompetitionRegistrationState(
        collections: collections ?? this.collections,
        loadingStatus: loadingStatus ?? this.loadingStatus,
        formStep: formStep ?? this.formStep,
        competition: competition ?? this.competition,
        partner: partner ?? this.partner,
        competitionType: competitionType ?? this.competitionType,
        genderCategory: genderCategory ?? this.genderCategory,
        ageGroup: ageGroup ?? this.ageGroup,
        playingLevel: playingLevel ?? this.playingLevel,
        dialog: dialog ?? this.dialog,
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

  P? getCompetitionParameter<P>() {
    return inputs.whereType<FormzInput<P?, Object>>().first.value;
  }

  List<FormzInput> get inputs =>
      [playingLevel, ageGroup, genderCategory, competitionType];
}
