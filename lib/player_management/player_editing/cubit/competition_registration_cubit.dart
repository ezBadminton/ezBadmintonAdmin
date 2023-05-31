import 'package:collection/collection.dart';
import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/collection_queries/collection_querier.dart';
import 'package:ez_badminton_admin_app/input_models/models.dart';
import 'package:ez_badminton_admin_app/input_models/no_validation.dart';
import 'package:ez_badminton_admin_app/player_management/models/competition_registration.dart';
import 'package:ez_badminton_admin_app/player_management/player_editing/cubit/competition_registration_state.dart';
import 'package:ez_badminton_admin_app/player_management/player_editing/models/registration_warning.dart';
import 'package:ez_badminton_admin_app/player_management/utils/age_groups.dart';
import 'package:ez_badminton_admin_app/player_management/utils/gender_categories.dart';
import 'package:ez_badminton_admin_app/player_management/utils/playing_levels.dart';
import 'package:ez_badminton_admin_app/widgets/loading_screen/loading_screen.dart';

class CompetitionRegistrationCubit
    extends CollectionFetcherCubit<CompetitionRegistrationState> {
  CompetitionRegistrationCubit({
    required this.player,
    required this.registrations,
    required CollectionRepository<Player> playerRepository,
    required CollectionRepository<Competition> competitionRepository,
    required CollectionRepository<PlayingLevel> playingLevelRepository,
    required CollectionRepository<AgeGroup> ageGroupRepository,
  }) : super(
          CompetitionRegistrationState(),
          collectionRepositories: [
            playerRepository,
            competitionRepository,
            playingLevelRepository,
            ageGroupRepository,
          ],
        ) {
    loadPlayerData();
  }

  final Player player;
  final List<CompetitionRegistration> registrations;

  late List<List<Type>> allFormSteps;

  void loadPlayerData() {
    if (state.loadingStatus != LoadingStatus.loading) {
      emit(state.copyWith(loadingStatus: LoadingStatus.loading));
    }
    fetchCollectionsAndUpdateState(
      [
        collectionFetcher<Player>(),
        collectionFetcher<Competition>(),
        collectionFetcher<PlayingLevel>(),
        collectionFetcher<AgeGroup>(),
      ],
      onSuccess: (updatedState) {
        updatedState = updatedState.copyWith(
          loadingStatus: LoadingStatus.done,
        );

        emit(updatedState);
        var baseFormSteps = [
          [PlayingLevel],
          [AgeGroup],
          [GenderCategory, CompetitionType],
          [Player],
        ];
        if (getParameterOptions<PlayingLevel>().isEmpty) {
          baseFormSteps.removeWhere((step) => step.contains(PlayingLevel));
        }
        if (getParameterOptions<AgeGroup>().isEmpty) {
          baseFormSteps.removeWhere((step) => step.contains(AgeGroup));
        }
        allFormSteps = baseFormSteps;
      },
      onFailure: () =>
          emit(state.copyWith(loadingStatus: LoadingStatus.failed)),
    );
  }

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

  void formSubmitted({bool ignoreWarnings = false}) {
    var selection = getSelectedCompetitions();
    assert(
      selection.length == 1,
      'Registration form did not select only one competition',
    );
    var selected = selection.first;
    CompetitionRegistrationState newState;
    if (ignoreWarnings) {
      newState = state.copyWith(warnings: []);
    } else {
      newState = _createWarnings(selected);
    }
    newState = newState.copyWith(
      competition: SelectionInput.dirty(value: selected),
    );
    assert(newState.isValid);
    emit(newState);
  }

  void warningsDismissed(bool doContinue) {
    if (doContinue) {
      formSubmitted(ignoreWarnings: true);
    } else {
      var newState = state.copyWith(
        warnings: [],
        competition: const SelectionInput.dirty(value: null),
      );
      emit(newState);
    }
  }

  CompetitionRegistrationState _createWarnings(Competition selected) {
    var warnings = List.of(state.warnings);
    if (!_verifyAgeGroup(selected)) {
      warnings.add(
        AgeGroupWarning(unfitAgeGroups: selected.ageGroups, player: player),
      );
    }
    if (!_verifyPlayingLevel(selected)) {
      warnings.add(
        PlayingLevelWarning(
          unfitPlayingLevels: selected.playingLevels,
          player: player,
        ),
      );
    }
    if (!_verifyGenderCategory(selected)) {
      warnings.add(
        GenderWarning(conflictingGender: selected.genderCategory),
      );
    }
    return state.copyWith(warnings: warnings);
  }

  bool _verifyAgeGroup(Competition competition) {
    if (player.dateOfBirth == null || competition.ageGroups.isEmpty) {
      return true;
    }
    var playerAgeGroups = ageToAgeGroups(
      player.calculateAge(),
      state.getCollection<AgeGroup>(),
    );
    return playerAgeGroups
        .where((group) => competition.ageGroups.contains(group))
        .isNotEmpty;
  }

  bool _verifyPlayingLevel(Competition competition) {
    if (player.playingLevel == null || competition.playingLevels.isEmpty) {
      return true;
    }
    var comparison =
        player.playingLevel!.compareToList(competition.playingLevels);
    return comparison == 0;
  }

  bool _verifyGenderCategory(Competition competition) {
    var present = registrations.map((c) => c.competition.genderCategory);
    return !competition.genderCategory.isConflicting(present);
  }

  void formStepBackTo(int step) {
    assert(step >= 0 && step <= lastFormStep);
    if (step >= state.formStep) {
      return;
    }
    while (state.formStep > step) {
      formStepBack();
    }
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
  /// [Competition]s in the collection that the player is not registered for.
  ///
  /// If [inSelection] is `true` the Competitions are pre-filered by the
  /// parameters that are already set (the "selected" competitions).
  List<P> getParameterOptions<P extends Object>({bool inSelection = false}) {
    var selectedCompetitions = inSelection
        ? getSelectedCompetitions(ignore: [P])
        : state.getCollection<Competition>();
    selectedCompetitions.removeWhere(
      (c) => registrations.map((r) => r.competition).contains(c),
    );
    switch (P) {
      case PlayingLevel:
        return selectedCompetitions
            .expand((competition) => competition.playingLevels)
            .toSet()
            .sorted((a, b) => a.index > b.index ? 1 : -1) as List<P>;
      case AgeGroup:
        return selectedCompetitions
            .expand((competition) => competition.ageGroups)
            .toSet()
            .sorted((a, b) => a.age > b.age ? 1 : -1) as List<P>;
      case GenderCategory:
        var presentGenderCategories =
            selectedCompetitions.map((c) => c.genderCategory);
        return GenderCategory.values
            .where((t) => presentGenderCategories.contains(t))
            .toList() as List<P>;
      case CompetitionType:
        var presentCompetitionTypes = selectedCompetitions.map((c) => c.type);
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
  /// The parameter types in the [ignore] list are not used for matching.
  /// In order to successfully submit the competition registration form the list
  /// needs to be of length 1.
  List<Competition> getSelectedCompetitions({List<Type> ignore = const []}) {
    return state.getCollection<Competition>().where((competition) {
      var typeMatch = ignore.contains(CompetitionType) ||
          state.competitionType.value == null ||
          competition.type == state.competitionType.value;
      var genderCategoryMatch = ignore.contains(GenderCategory) ||
          state.genderCategory.value == null ||
          competition.genderCategory == state.genderCategory.value;
      var ageGroupMatch = ignore.contains(AgeGroup) ||
          state.ageGroup.value == null ||
          competition.ageGroups.isEmpty ||
          competition.ageGroups.contains(state.ageGroup.value);
      var playingLevelMatch = ignore.contains(PlayingLevel) ||
          state.playingLevel.value == null ||
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

  void partnerNameChanged(String partnerName) {
    var newState =
        state.copyWith(partnerName: NoValidationInput.dirty(partnerName));
    emit(newState);
  }

  void partnerChanged(Player? partner) {
    var newState = state.copyWith(
      partner: SelectionInput.dirty(emptyAllowed: true, value: partner),
    );
    emit(newState);
  }
}
