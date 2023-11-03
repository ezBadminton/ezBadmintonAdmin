import 'package:collection/collection.dart';
import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/collection_queries/collection_querier.dart';
import 'package:ez_badminton_admin_app/competition_management/models/competition_category.dart';
import 'package:ez_badminton_admin_app/competition_management/models/playing_category.dart';
import 'package:ez_badminton_admin_app/competition_management/utils/competition_categorization.dart';
import 'package:ez_badminton_admin_app/utils/sorting.dart';
import 'package:ez_badminton_admin_app/widgets/loading_screen/loading_screen.dart';
import 'package:formz/formz.dart';

part 'competition_adding_state.dart';

class CompetitionAddingCubit
    extends CollectionFetcherCubit<CompetitionAddingState> {
  CompetitionAddingCubit({
    required CollectionRepository<Competition> competitionRepository,
    required CollectionRepository<AgeGroup> ageGroupRepository,
    required CollectionRepository<PlayingLevel> playingLevelRepository,
    required CollectionRepository<Tournament> tournamentRepository,
  }) : super(
          collectionRepositories: [
            competitionRepository,
            ageGroupRepository,
            playingLevelRepository,
            tournamentRepository
          ],
          CompetitionAddingState(),
        ) {
    loadCompetitionData();
  }

  void loadCompetitionData() {
    fetchCollectionsAndUpdateState(
      [
        collectionFetcher<Competition>(),
        collectionFetcher<AgeGroup>(),
        collectionFetcher<PlayingLevel>(),
        collectionFetcher<Tournament>(),
      ],
      onSuccess: (updatedState) {
        updatedState = updatedState.copyWithAgeGroupSorting();
        updatedState = updatedState.copyWithPlayingLevelSorting();
        updatedState = _updateDisabledOptions(updatedState);

        emit(updatedState.copyWith(loadingStatus: LoadingStatus.done));
      },
      onFailure: () {
        emit(state.copyWith(loadingStatus: LoadingStatus.failed));
      },
    );
  }

  void ageGroupToggled(AgeGroup ageGroup) {
    if (state.disabledAgeGroups.contains(ageGroup)) {
      return;
    }
    List<AgeGroup> newAgeGroups = List.of(state.ageGroups);
    _optionToggle(newAgeGroups, ageGroup);
    newAgeGroups.sort(compareAgeGroups);
    var newState = state.copyWith(ageGroups: newAgeGroups);
    newState = _updateDisabledOptions(newState);
    emit(newState);
  }

  void playingLevelToggled(PlayingLevel playingLevel) {
    if (state.disabledPlayingLevels.contains(playingLevel)) {
      return;
    }
    List<PlayingLevel> newPlayingLevels = List.of(state.playingLevels);
    _optionToggle(newPlayingLevels, playingLevel);
    newPlayingLevels.sortBy<num>((lvl) => lvl.index);
    var newState = state.copyWith(playingLevels: newPlayingLevels);
    newState = _updateDisabledOptions(newState);
    emit(newState);
  }

  void competitionDisciplineToggled(CompetitionDiscipline competitionCategory) {
    if (state.disabledCompetitionDisciplines.contains(competitionCategory)) {
      return;
    }
    List<CompetitionDiscipline> newCompetitionCategories =
        List.of(state.competitionDisciplines);
    _optionToggle(newCompetitionCategories, competitionCategory);
    var newState = state.copyWith(
      competitionDisciplines: newCompetitionCategories,
    );
    newState = _unselectDisabledOptions(newState);
    emit(newState);
  }

  void formSubmitted() async {
    if (!state.submittable ||
        state.formStatus == FormzSubmissionStatus.inProgress) {
      return;
    }

    List<PlayingCategory> selectedCategories =
        _getSelectedPlayingCategories(state);

    List<Competition> newCompetitions = [
      for (PlayingCategory category in selectedCategories)
        for (CompetitionDiscipline baseCompetition
            in state.competitionDisciplines)
          Competition.newCompetition(
            teamSize: baseCompetition.competitionType == CompetitionType.singles
                ? 1
                : 2,
            genderCategory: baseCompetition.genderCategory,
            ageGroup: category.ageGroup,
            playingLevel: category.playingLevel,
          ),
    ];

    emit(state.copyWith(formStatus: FormzSubmissionStatus.inProgress));

    for (Competition competition in newCompetitions) {
      Competition? createdCompetition = await querier.createModel(competition);
      if (createdCompetition == null) {
        emit(state.copyWith(formStatus: FormzSubmissionStatus.failure));
        return;
      }
    }

    emit(state.copyWith(formStatus: FormzSubmissionStatus.success));
  }

  static void _optionToggle(List optionList, Object option) {
    if (optionList.contains(option)) {
      optionList.remove(option);
    } else {
      optionList.add(option);
    }
  }

  /// Disable competition creation options such that existing competitions can't
  /// be duplicated.
  static CompetitionAddingState _updateDisabledOptions(
    CompetitionAddingState state,
  ) {
    List<Competition> existingCompetitions = state.getCollection<Competition>();

    Tournament tournament = state.getCollection<Tournament>().first;

    List<PlayingCategory> possibleCategories = getPossiblePlayingCategories(
      tournament,
      state.getCollection<AgeGroup>(),
      state.getCollection<PlayingLevel>(),
    );

    Map<PlayingCategory, List<CompetitionDiscipline>> existingCategories =
        mapPlayingCategories(possibleCategories, existingCompetitions);

    Map<CompetitionDiscipline, List<PlayingCategory>> existingBaseCompetitions =
        mapDisciplines(existingCompetitions);

    List<PlayingCategory> creatableCategories = possibleCategories
        .where(
          (category) =>
              existingCategories[category]!.length <
              CompetitionDiscipline.baseCompetitions.length,
        )
        .toList();

    Set<AgeGroup> creatableAgeGroups = creatableCategories
        .map((c) => c.ageGroup)
        .whereType<AgeGroup>()
        .toSet();

    Set<PlayingLevel> creatablePlayingLevels = creatableCategories
        .map((c) => c.playingLevel)
        .whereType<PlayingLevel>()
        .toSet();

    Set<CompetitionDiscipline> creatableBaseCompetitions =
        CompetitionDiscipline.baseCompetitions
            .where(
              (baseCompetition) =>
                  existingBaseCompetitions[baseCompetition]!.length <
                  possibleCategories.length,
            )
            .toSet();

    creatablePlayingLevels.removeAll(
      _getIncompatibleSelection<PlayingLevel>(
        state.ageGroups,
        existingCategories,
      ),
    );

    creatableAgeGroups.removeAll(
      _getIncompatibleSelection<AgeGroup>(
        state.playingLevels,
        existingCategories,
      ),
    );

    List<PlayingCategory> selectedPlayingCategories =
        _getSelectedPlayingCategories(state);
    _disableIncompatibleBaseCompetitions(
      selectedPlayingCategories,
      existingCategories,
      creatableBaseCompetitions,
    );

    Set<CompetitionDiscipline> disabledBaseCompetitions = CompetitionDiscipline
        .baseCompetitions
        .toSet()
        .difference(creatableBaseCompetitions);

    Set<AgeGroup> disabledAgeGroups = tournament.useAgeGroups
        ? state.getCollection<AgeGroup>().toSet().difference(creatableAgeGroups)
        : {};

    Set<PlayingLevel> disabledPlayingLevels = tournament.usePlayingLevels
        ? state
            .getCollection<PlayingLevel>()
            .toSet()
            .difference(creatablePlayingLevels)
        : {};

    var newState = state.copyWith(
      disabledCompetitionDisciplines: disabledBaseCompetitions,
      disabledAgeGroups: disabledAgeGroups,
      disabledPlayingLevels: disabledPlayingLevels,
    );
    newState = _unselectDisabledOptions(newState);

    return newState;
  }

  /// Unselects any options that are selected and on the list of
  /// disabled options.
  static CompetitionAddingState _unselectDisabledOptions(
    CompetitionAddingState state,
  ) {
    List<AgeGroup> ageGroups = state.ageGroups
        .whereNot(
          (ageGroup) => state.disabledAgeGroups.contains(ageGroup),
        )
        .toList();
    List<PlayingLevel> playingLevels = state.playingLevels
        .whereNot(
          (playingLevel) => state.disabledPlayingLevels.contains(playingLevel),
        )
        .toList();
    List<CompetitionDiscipline> competitionCategories =
        state.competitionDisciplines
            .whereNot(
              (competitionCategory) => state.disabledCompetitionDisciplines
                  .contains(competitionCategory),
            )
            .toList();

    return state.copyWith(
      ageGroups: ageGroups,
      playingLevels: playingLevels,
      competitionDisciplines: competitionCategories,
    );
  }

  /// Returns the list of [PlayingCategory]s that is created from the current
  /// selection of [selectedAgeGroups] and [selectedPlayingLevels].
  ///
  /// It is a subset of [getPossiblePlayingCategories].
  /// It's empty when no category selection has been made.
  static List<PlayingCategory> _getSelectedPlayingCategories(
    CompetitionAddingState state,
  ) {
    List<PlayingCategory> selectedPlayingCategories = [];

    bool useAgeGroups = state.getCollection<Tournament>().first.useAgeGroups;
    bool usePlayingLevels =
        state.getCollection<Tournament>().first.usePlayingLevels;

    if (useAgeGroups == state.ageGroups.isNotEmpty &&
        usePlayingLevels == state.playingLevels.isNotEmpty) {
      List<AgeGroup?> ageGroups =
          state.ageGroups.isEmpty ? [null] : state.ageGroups;
      List<PlayingLevel?> playingLevels =
          state.playingLevels.isEmpty ? [null] : state.playingLevels;

      selectedPlayingCategories = [
        for (AgeGroup? ageGroup in ageGroups)
          for (PlayingLevel? playingLevel in playingLevels)
            PlayingCategory(
              ageGroup: ageGroup,
              playingLevel: playingLevel,
            ),
      ];
    }

    return selectedPlayingCategories;
  }

  /// Returns the set of [C] categories that cannot be selected due to
  /// incompatibility with [selectedCategories].
  ///
  /// See also:
  /// * [_getIncompatibleCategories] finds the incompatible categories of each
  /// selected category.
  static Set<C> _getIncompatibleSelection<C extends Model>(
    List<Model> selectedCategories,
    Map<PlayingCategory, List<CompetitionDiscipline>> existingCategories,
  ) {
    Set<C> incompatibleCategories = {
      for (Model category in selectedCategories)
        ..._getIncompatibleCategories(
          category,
          existingCategories,
        ),
    };

    return incompatibleCategories;
  }

  /// Returns the set of [C] categories that are incompatible with [category]
  /// due to their combined [PlayingCategory] already having all
  /// base disciplines.
  ///
  /// [C] is either [AgeGroup] or [PlayingLevel]. [category] has to be of
  /// the opposite type.
  static Set<C> _getIncompatibleCategories<C extends Model>(
    Model category,
    Map<PlayingCategory, List<CompetitionDiscipline>> existingCategories,
  ) {
    assert(C == AgeGroup || C == PlayingLevel);
    assert(category is AgeGroup || category is PlayingLevel);
    assert(category is! C);

    Map<PlayingCategory, List<CompetitionDiscipline>> fullPlayingCategories =
        Map.of(existingCategories)
          ..removeWhere(
            (playingCategory, disciplines) =>
                !playingCategory.isInCategory(category) ||
                disciplines.length <
                    CompetitionDiscipline.baseCompetitions.length,
          );

    Set<C> incompatibleCategories = fullPlayingCategories.keys
        .map((playingCategory) => playingCategory.getCategory<C>()!)
        .toSet();

    return incompatibleCategories;
  }

  /// Updates the [creatableBaseCompetitions] to be compatible with the
  /// currently selected playing categories.
  ///
  /// When one of the selected playing categories already has some competitions
  /// created in it, then these base competitions are disabled to prevent
  /// duplicate creation.
  static void _disableIncompatibleBaseCompetitions(
    List<PlayingCategory> selectedPlayingCategories,
    Map<PlayingCategory, List<CompetitionDiscipline>> existingCategories,
    Set<CompetitionDiscipline> creatableBaseCompetitions,
  ) {
    for (PlayingCategory playingCategory in selectedPlayingCategories) {
      creatableBaseCompetitions.removeAll(
        existingCategories[playingCategory]!,
      );
    }
  }
}
