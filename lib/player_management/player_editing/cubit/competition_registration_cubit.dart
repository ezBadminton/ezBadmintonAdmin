import 'package:collection/collection.dart';
import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/collection_queries/collection_querier.dart';
import 'package:ez_badminton_admin_app/input_models/no_validation.dart';
import 'package:ez_badminton_admin_app/player_management/player_editing/cubit/competition_registration_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CompetitionRegistrationCubit extends Cubit<CompetitionRegistrationState>
    with CollectionGetter {
  CompetitionRegistrationCubit(
    super.initialState, {
    required this.registrationIndex,
    required Map<Type, List<Model>> playerListCollections,
  }) : collections = playerListCollections {
    var formSteps = [
      [PlayingLevel],
      [AgeGroup],
      [GenderCategory, CompetitionType],
      [Player],
    ];
    if (getParameterOptions<PlayingLevel>().isEmpty) {
      formSteps.removeWhere((step) => step.contains(PlayingLevel));
    }
    if (getParameterOptions<AgeGroup>().isEmpty) {
      formSteps.removeWhere((step) => step.contains(AgeGroup));
    }
    allFormSteps = formSteps;
  }

  final int registrationIndex;
  @override
  final Map<Type, List<Model>> collections;

  late List<List<Type>> allFormSteps;

  int get lastFormStep {
    int lastStep = allFormSteps.length - 1;
    // The form is shorter when no playing levels/age groups are configured
    if (getParameterOptions<PlayingLevel>().isEmpty) {
      lastStep--;
    }
    if (getParameterOptions<AgeGroup>().isEmpty) {
      lastStep--;
    }
    return lastStep;
  }

  void formStepForward() {
    if (state.formStep >= lastFormStep) {
      return;
    }
    var newState = state.copyWith(formStep: state.formStep + 1);
    emit(newState);
  }

  void formStepBack() {
    if (state.formStep == 0) {
      return;
    }
    resetFormStep(state.formStep);
    resetFormStep(state.formStep - 1);
    var newState = state.copyWith(formStep: state.formStep - 1);
    emit(newState);
  }

  /// Returns the set of values that are present for a parameter [P] on all
  /// [Competition]s in the collection.
  ///
  /// If [inSelection] is `true` the Competitions are pre-filered by the
  /// parameters that are already set (the "selected" competitions).
  List<P> getParameterOptions<P extends Object>({bool inSelection = false}) {
    var selectedCompetitions =
        inSelection ? getSelectedCompetitions() : getCollection<Competition>();
    switch (P) {
      case PlayingLevel:
        return selectedCompetitions
            .map((c) => c.playingLevels)
            .expand((levels) => levels)
            .toSet()
            .sorted((a, b) => a.index > b.index ? 1 : -1) as List<P>;
      case AgeGroup:
        return selectedCompetitions
            .map((c) => c.ageGroups)
            .expand((groups) => groups)
            .toSet()
            .sorted((a, b) => a.age > b.age ? 1 : -1) as List<P>;
      case GenderCategory:
        var presentGenderCategories =
            selectedCompetitions.map((c) => c.genderCategory);
        return GenderCategory.values
            .where((t) => presentGenderCategories.contains(t))
            .toList() as List<P>;
      case CompetitionType:
        var presentCompetitionTypes =
            selectedCompetitions.map((c) => c.getCompetitionType());
        return CompetitionType.values
            .where((t) => presentCompetitionTypes.contains(t))
            .toList() as List<P>;
      default:
        assert(false, 'Unknown competition parameter type');
        return [];
    }
  }

  /// Returns the List of [Competition]s that match the currently set
  /// parameters.
  ///
  /// In order to successfully sumbit the competition registration form the list
  /// needs to be of length 1.
  List<Competition> getSelectedCompetitions() {
    return getCollection<Competition>().where((competition) {
      var typeMatch = state.competitionType.value == null ||
          competition.getCompetitionType() == state.competitionType.value;
      var genderCategoryMatch = state.genderCategory.value == null ||
          competition.genderCategory == state.genderCategory.value;
      var ageGroupMatch = state.ageGroup.value == null ||
          competition.ageGroups.isEmpty ||
          competition.ageGroups.contains(state.ageGroup.value);
      var playingLevelMatch = state.playingLevel.value == null ||
          competition.playingLevels.isEmpty ||
          competition.playingLevels.contains(state.playingLevel.value);
      return typeMatch &&
          genderCategoryMatch &&
          ageGroupMatch &&
          playingLevelMatch;
    }).toList();
  }

  void competitionParameterChanged<P>(P? parameter) {
    if (parameter == null) {
      return;
    }
    var newState = state.copyWithCompetitionParameter<P>(parameter);
    if ([PlayingLevel, AgeGroup].contains(P)) {
      newState = newState.copyWith(formStep: state.formStep + 1);
    }
    if ([GenderCategory, CompetitionType].contains(P)) {
      if (parameter == GenderCategory.mixed) {
        newState = newState.copyWithCompetitionParameter<CompetitionType>(
          CompetitionType.mixed,
        );
      } else if (parameter == CompetitionType.mixed) {
        newState = newState.copyWithCompetitionParameter<GenderCategory>(
          GenderCategory.mixed,
        );
      }
      if (newState.getCompetitionParameter<GenderCategory>() != null &&
          newState.getCompetitionParameter<CompetitionType>() != null) {
        newState = newState.copyWith(formStep: state.formStep + 1);
      }
    }
    emit(newState);
  }

  void resetFormStep<P>(int formStep) {
    var newState = state;
    for (var parameterType in getFormStepParameterTypes(formStep)) {
      switch (parameterType) {
        case PlayingLevel:
          newState = newState.copyWithCompetitionParameter<PlayingLevel>(null);
          break;
        case AgeGroup:
          newState = newState.copyWithCompetitionParameter<AgeGroup>(null);
          break;
        case GenderCategory:
          newState =
              newState.copyWithCompetitionParameter<GenderCategory>(null);
          break;
        case CompetitionType:
          newState =
              newState.copyWithCompetitionParameter<CompetitionType>(null);
          break;
        case Player:
          newState = newState.copyWith(
            partnerName: const NoValidationInput.dirty(''),
          );
          break;
        default:
          assert(false, 'Unknown competition parameter type');
      }
    }
    emit(newState);
  }

  int getFormStepFromParameterType<P>() {
    int step;
    for (step = 0; step <= lastFormStep; step++) {
      if (getFormStepParameterTypes(step).contains(P)) {
        return step;
      }
    }
    assert(false, 'The given parameter type is not present in the form');
    return 0;
  }

  List<Type> getFormStepParameterTypes(int formStep) {
    return allFormSteps[formStep];
  }

  void partnerNameChanged(int registrationIndex, String partnerName) {
    var newState =
        state.copyWith(partnerName: NoValidationInput.dirty(partnerName));
    emit(newState);
  }
}
