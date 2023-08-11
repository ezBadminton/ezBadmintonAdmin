import 'package:collection/collection.dart';
import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/collection_queries/collection_querier.dart';
import 'package:ez_badminton_admin_app/input_models/models.dart';
import 'package:ez_badminton_admin_app/player_management/models/competition_registration.dart';
import 'package:ez_badminton_admin_app/player_management/player_editing/cubit/competition_registration_state.dart';
import 'package:ez_badminton_admin_app/player_management/player_editing/models/registration_warning.dart';
import 'package:ez_badminton_admin_app/player_management/utils/gender_categories.dart';
import 'package:ez_badminton_admin_app/widgets/dialog_listener/cubit_mixin/dialog_cubit.dart';
import 'package:ez_badminton_admin_app/widgets/loading_screen/loading_screen.dart';

class CompetitionRegistrationCubit
    extends CollectionFetcherCubit<CompetitionRegistrationState>
    with DialogCubit<CompetitionRegistrationState> {
  CompetitionRegistrationCubit({
    required this.player,
    required this.registrations,
    required CollectionRepository<Player> playerRepository,
    required CollectionRepository<Competition> competitionRepository,
    required CollectionRepository<AgeGroup> ageGroupRepository,
    required CollectionRepository<Tournament> tournamentRepository,
  }) : super(
          CompetitionRegistrationState(),
          collectionRepositories: [
            playerRepository,
            competitionRepository,
            ageGroupRepository,
            tournamentRepository,
          ],
        ) {
    loadCollections();
    subscribeToCollectionUpdates(
      competitionRepository,
      _competitionCollectionUpdated,
    );
  }

  final Player player;
  final List<CompetitionRegistration> registrations;

  late List<List<Type>> allFormSteps;

  void loadCollections() {
    if (state.loadingStatus != LoadingStatus.loading) {
      emit(state.copyWith(loadingStatus: LoadingStatus.loading));
    }
    fetchCollectionsAndUpdateState(
      [
        collectionFetcher<Player>(),
        collectionFetcher<Competition>(),
        collectionFetcher<AgeGroup>(),
        collectionFetcher<Tournament>(),
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

  int get lastFormStep => allFormSteps.length - 1;

  void formSubmitted() async {
    var selection = getSelectedCompetitions();
    assert(
      selection.length == 1,
      'Registration form did not select only one competition',
    );
    var selected = selection.first;

    List<RegistrationWarning> warnings = _createWarnings(selected);
    bool userConfirmation = true;
    if (warnings.isNotEmpty) {
      userConfirmation = (await requestDialogChoice<bool>(reason: warnings))!;
    }

    CompetitionRegistrationState newState;
    if (userConfirmation) {
      newState = state.copyWith(
        competition: SelectionInput.dirty(value: selected),
      );
    } else {
      newState = state.copyWith(
        competition: const SelectionInput.dirty(value: null),
      );
    }

    emit(newState);
  }

  List<RegistrationWarning> _createWarnings(Competition selected) {
    List<RegistrationWarning> warnings = [];
    if (!_verifyGenderCategory(selected)) {
      warnings.add(
        GenderWarning(conflictingGender: selected.genderCategory),
      );
    }
    return warnings;
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

  /// Returns the set of values that are possible for a parameter [P] on all
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
            .map((competition) => competition.playingLevel)
            .whereType<PlayingLevel>()
            .toSet()
            .sorted((a, b) => a.index > b.index ? 1 : -1) as List<P>;
      case AgeGroup:
        return selectedCompetitions
            .map((competition) => competition.ageGroup)
            .whereType<AgeGroup>()
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
          competition.ageGroup == null ||
          competition.ageGroup == state.ageGroup.value;
      var playingLevelMatch = ignore.contains(PlayingLevel) ||
          state.playingLevel.value == null ||
          competition.playingLevel == null ||
          competition.playingLevel == state.playingLevel.value;
      return typeMatch &&
          genderCategoryMatch &&
          ageGroupMatch &&
          playingLevelMatch;
    }).toList();
  }

  /// Updates the state with a [parameter] of one of the Competition parameter
  /// types [PlayingLevel], [AgeGroup], [GenderCategory] or [CompetitionType].
  ///
  /// The registration form step is incremented whenever all parameters of
  /// that step have been set. Once all parameter types are set with a value,
  /// a single competition has been selected.
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

  void partnerChanged(Player? partner) {
    var newState = state.copyWith(
      partner: SelectionInput.dirty(emptyAllowed: true, value: partner),
    );
    emit(newState);
  }

  // Sets all parameters of a form step back to null.
  void resetFormStep(int formStep) {
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
            partner: const SelectionInput.dirty(),
          );
          break;
        default:
          assert(false, 'Unknown competition parameter type');
      }
    }
    emit(newState);
  }

  /// Returns the form step in which the parameter type [P] is put in.
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

  /// Returns the types of the competition parameters that are put in during
  /// the given [formStep]
  List<Type> getFormStepParameterTypes(int formStep) {
    return allFormSteps[formStep];
  }

  /// When the competitions change while this form is open, it is reset
  void _competitionCollectionUpdated(CollectionUpdateEvent event) {
    Competition updatedCompetition = event.model as Competition;
    // Do not update when the categorization changed because the registration
    // form has to be closed by the PlayerEditingCubit anyways in this case
    if (!_didCategorizationChange(updatedCompetition)) {
      formStepBackTo(0);
      loadCollections();
    }
  }

  bool _didCategorizationChange(Competition competition) {
    Tournament tournament = state.getCollection<Tournament>().first;
    return (competition.ageGroup != null) != tournament.useAgeGroups ||
        (competition.playingLevel != null) != tournament.usePlayingLevels;
  }
}
