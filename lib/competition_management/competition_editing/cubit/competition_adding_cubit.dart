import 'package:collection/collection.dart';
import 'package:collection_repository/collection_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:ez_badminton_admin_app/collection_queries/collection_querier.dart';
import 'package:ez_badminton_admin_app/competition_management/models/competition_category.dart';
import 'package:ez_badminton_admin_app/competition_management/utils/sorting.dart';
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
          const CompetitionAddingState(),
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

  void competitionCategoryToggled(CompetitionCategory competitionCategory) {
    if (state.disabledCompetitionCategories.contains(competitionCategory)) {
      return;
    }
    List<CompetitionCategory> newCompetitionCategories =
        List.of(state.competitionCategories);
    _optionToggle(newCompetitionCategories, competitionCategory);
    var newState = state.copyWith(
      competitionCategories: newCompetitionCategories,
    );
    newState = _unselectDisabledOptions(newState);
    emit(newState);
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

    bool useAgeGroups = state.getCollection<Tournament>().first.useAgeGroups;
    bool usePlayingLevels =
        state.getCollection<Tournament>().first.usePlayingLevels;

    List<AgeGroup?> ageGroups =
        useAgeGroups ? state.getCollection<AgeGroup>() : [null];
    List<PlayingLevel?> playingLevels =
        usePlayingLevels ? state.getCollection<PlayingLevel>() : [null];

    List<_PlayingCategory> possibleCategories =
        _getPossiblePlayingCategories(ageGroups, playingLevels);

    Map<_PlayingCategory, List<CompetitionCategory>> existingCategories =
        _mapPlayingCategories(possibleCategories, existingCompetitions);

    Map<CompetitionCategory, List<_PlayingCategory>> existingBaseCompetitions =
        _mapBaseCompetitions(existingCompetitions);

    List<_PlayingCategory> creatableCategories = possibleCategories
        .where(
          (category) =>
              existingCategories[category]!.length <
              CompetitionCategory.defaultCompetitions.length,
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

    Set<CompetitionCategory> creatableBaseCompetitions =
        CompetitionCategory.defaultCompetitions
            .where(
              (baseCompetition) =>
                  existingBaseCompetitions[baseCompetition]!.length <
                  possibleCategories.length,
            )
            .toSet();

    _disableIncompatiblePlayingLevels(
      state.ageGroups,
      existingCategories,
      creatablePlayingLevels,
    );

    _disableIncompatibleAgeGroups(
      state.playingLevels,
      existingCategories,
      creatableAgeGroups,
    );

    List<_PlayingCategory> selectedPlayingCategories =
        _getSelectedPlayingCategories(
      useAgeGroups,
      usePlayingLevels,
      state.ageGroups,
      state.playingLevels,
    );
    _disableIncompatibleBaseCompetitions(
      selectedPlayingCategories,
      existingCategories,
      creatableBaseCompetitions,
    );

    Set<CompetitionCategory> disabledBaseCompetitions = CompetitionCategory
        .defaultCompetitions
        .toSet()
        .difference(creatableBaseCompetitions);

    Set<AgeGroup> disabledAgeGroups =
        ageGroups.whereType<AgeGroup>().toSet().difference(creatableAgeGroups);

    Set<PlayingLevel> disabledPlayingLevels = playingLevels
        .whereType<PlayingLevel>()
        .toSet()
        .difference(creatablePlayingLevels);

    var newState = state.copyWith(
      disabledCompetitionCategories: disabledBaseCompetitions,
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
    List<PlayingLevel> playingLevel = state.playingLevels
        .whereNot(
          (playingLevel) => state.disabledPlayingLevels.contains(playingLevel),
        )
        .toList();
    List<CompetitionCategory> competitionCategories = state
        .competitionCategories
        .whereNot(
          (competitionCategory) =>
              state.disabledCompetitionCategories.contains(competitionCategory),
        )
        .toList();

    return state.copyWith(
      ageGroups: ageGroups,
      playingLevels: playingLevel,
      competitionCategories: competitionCategories,
    );
  }

  /// Creates a list of all possible [_PlayingCategory]s.
  ///
  /// The list contains a [_PlayingCategory] for each combination
  /// of [AgeGroup] and [PlayingLevel] that comes
  /// from the [ageGroups] and [playingLevels] lists.
  ///
  /// Example:
  ///
  /// With `ageGroups = [O19, U19]` and `playingLevels = [beginner, pro]`
  /// the possible playing categories would be
  /// * `O19 beginner`
  /// * `O19 pro`
  /// * `U19 beginner`
  /// * `U19 pro`
  static List<_PlayingCategory> _getPossiblePlayingCategories(
    List<AgeGroup?> ageGroups,
    List<PlayingLevel?> playingLevels,
  ) {
    return [
      for (AgeGroup? ageGroup in ageGroups)
        for (PlayingLevel? playingLevel in playingLevels)
          _PlayingCategory(ageGroup: ageGroup, playingLevel: playingLevel),
    ];
  }

  /// Returns the list of [_PlayingCategory]s that is created from the current
  /// selection of [selectedAgeGroups] and [selectedPlayingLevels].
  ///
  /// It is a subset of [_getPossiblePlayingCategories]. If the current
  /// [Tournament] does not [useAgeGroups] or [usePlayingLevels] the list is
  /// always empty. Otherwise it's empty when no selection has been made.
  static List<_PlayingCategory> _getSelectedPlayingCategories(
    bool useAgeGroups,
    bool usePlayingLevels,
    List<AgeGroup> selectedAgeGroups,
    List<PlayingLevel> selectedPlayingLevels,
  ) {
    List<_PlayingCategory> selectedPlayingCategories = [];

    if ((useAgeGroups || usePlayingLevels) &&
        useAgeGroups == selectedAgeGroups.isNotEmpty &&
        usePlayingLevels == selectedPlayingLevels.isNotEmpty) {
      List<AgeGroup?> ageGroups =
          selectedAgeGroups.isEmpty ? [null] : selectedAgeGroups;
      List<PlayingLevel?> playingLevels =
          selectedPlayingLevels.isEmpty ? [null] : selectedPlayingLevels;

      selectedPlayingCategories = [
        for (AgeGroup? ageGroup in ageGroups)
          for (PlayingLevel? playingLevel in playingLevels)
            _PlayingCategory(
              ageGroup: ageGroup,
              playingLevel: playingLevel,
            ),
      ];
    }

    return selectedPlayingCategories;
  }

  /// Maps which base competitions exist in each [_PlayingCategory].
  ///
  /// Example: The O19 age group category
  /// maps to [men's singles, women's singles].
  ///
  /// It is the reverse mapping of [_mapBaseCompetitions].
  static Map<_PlayingCategory, List<CompetitionCategory>> _mapPlayingCategories(
    List<_PlayingCategory> possibleCategories,
    List<Competition> existingCompetitions,
  ) {
    Map<_PlayingCategory, List<CompetitionCategory>> existingCategories = {
      for (_PlayingCategory category in possibleCategories) category: [],
    };

    for (Competition competition in existingCompetitions) {
      List<AgeGroup?> competitionAgeGroups =
          competition.ageGroups.isEmpty ? [null] : competition.ageGroups;
      List<PlayingLevel?> competitionPlayingLevels =
          competition.playingLevels.isEmpty
              ? [null]
              : competition.playingLevels;
      var competitionCategory =
          CompetitionCategory.fromCompetition(competition);
      for (AgeGroup? ageGroup in competitionAgeGroups) {
        for (PlayingLevel? playingLevel in competitionPlayingLevels) {
          var playingCategory = _PlayingCategory(
            ageGroup: ageGroup,
            playingLevel: playingLevel,
          );

          assert(
            !existingCategories[playingCategory]!.contains(competitionCategory),
          );

          existingCategories[playingCategory]!.add(competitionCategory);
        }
      }
    }

    return existingCategories;
  }

  /// Maps which [_PlayingCategory]s exist in each base competition
  ///
  /// Example: men's doubles maps to [O19, U19, U17].
  ///
  /// It is the reverse mapping of [_mapPlayingCategories].
  static Map<CompetitionCategory, List<_PlayingCategory>> _mapBaseCompetitions(
    List<Competition> existingCompetitions,
  ) {
    Map<CompetitionCategory, List<_PlayingCategory>> existingBaseCompetitions =
        {
      for (CompetitionCategory baseCompetition
          in CompetitionCategory.defaultCompetitions)
        baseCompetition: [],
    };
    for (Competition competition in existingCompetitions) {
      List<AgeGroup?> competitionAgeGroups =
          competition.ageGroups.isEmpty ? [null] : competition.ageGroups;
      List<PlayingLevel?> competitionPlayingLevels =
          competition.playingLevels.isEmpty
              ? [null]
              : competition.playingLevels;
      var competitionCategory =
          CompetitionCategory.fromCompetition(competition);
      List<_PlayingCategory> playingCategories = [
        for (AgeGroup? ageGroup in competitionAgeGroups)
          for (PlayingLevel? playingLevel in competitionPlayingLevels)
            _PlayingCategory(
              ageGroup: ageGroup,
              playingLevel: playingLevel,
            ),
      ];

      assert(
        !playingCategories
            .map(
              (c) => existingBaseCompetitions[competitionCategory]!.contains(c),
            )
            .contains(true),
      );

      existingBaseCompetitions[competitionCategory]!.addAll(playingCategories);
    }

    return existingBaseCompetitions;
  }

  /// Updates the [creatablePlayingLevels] to be compatible with the currently
  /// [selectedAgeGroups].
  ///
  /// When an [AgeGroup] is selected and all base competitions in the
  /// combined category with a [PlayingLevel] already exist, then the
  /// [PlayingLevel] is disabled to prevent duplicate creation.
  static void _disableIncompatiblePlayingLevels(
    List<AgeGroup> selectedAgeGroups,
    Map<_PlayingCategory, List<CompetitionCategory>> existingCategories,
    Set<PlayingLevel> creatablePlayingLevels,
  ) {
    for (AgeGroup selectedAgeGroup in selectedAgeGroups) {
      Iterable<MapEntry<_PlayingCategory, List<CompetitionCategory>>>
          categoriesOfSelection = existingCategories.entries
              .where((entry) => entry.key.ageGroup == selectedAgeGroup);
      for (MapEntry<_PlayingCategory,
              List<CompetitionCategory>> categorizedBaseCompetitions
          in categoriesOfSelection) {
        // Check if all base competitions already exist
        if (categorizedBaseCompetitions.value.length ==
            CompetitionCategory.defaultCompetitions.length) {
          creatablePlayingLevels.remove(
            categorizedBaseCompetitions.key.playingLevel,
          );
        }
      }
    }
  }

  /// Updates the [creatableAgeGroups] to be compatible with the currently
  /// [selectedPlayingLevels].
  ///
  /// When a [PlayingLevel] is selected and all base competitions in the
  /// combined category with an [AgeGroup] already exist, then the
  /// [AgeGroup] is disabled to prevent duplicate creation.
  static void _disableIncompatibleAgeGroups(
    List<PlayingLevel> selectedPlayingLevels,
    Map<_PlayingCategory, List<CompetitionCategory>> existingCategories,
    Set<AgeGroup> creatableAgeGroups,
  ) {
    for (PlayingLevel selectedPlayingLevel in selectedPlayingLevels) {
      Iterable<MapEntry<_PlayingCategory, List<CompetitionCategory>>>
          categoriesOfSelection = existingCategories.entries
              .where((entry) => entry.key.playingLevel == selectedPlayingLevel);
      for (MapEntry<_PlayingCategory,
              List<CompetitionCategory>> categorizedBaseCompetitions
          in categoriesOfSelection) {
        // Check if all base competitions already exist
        if (categorizedBaseCompetitions.value.length ==
            CompetitionCategory.defaultCompetitions.length) {
          creatableAgeGroups.remove(
            categorizedBaseCompetitions.key.ageGroup,
          );
        }
      }
    }
  }

  /// Updates the [creatableBaseCompetitions] to be compatible with the
  /// currently selected playing categories.
  ///
  /// When one of the selected playing categories already has some competitions
  /// created in it, then these base competitions are disabled to prevent
  /// duplicate creation.
  static void _disableIncompatibleBaseCompetitions(
    List<_PlayingCategory> selectedPlayingCategories,
    Map<_PlayingCategory, List<CompetitionCategory>> existingCategories,
    Set<CompetitionCategory> creatableBaseCompetitions,
  ) {
    for (_PlayingCategory playingCategory in selectedPlayingCategories) {
      creatableBaseCompetitions.removeAll(
        existingCategories[playingCategory]!,
      );
    }
  }
}

/// A tuple of [ageGroup] and [playingLevel] forming a playing category.
///
/// [ageGroup] and [playingLevel] can be null when the current [Tournament]
/// does not use these categorizations.
class _PlayingCategory extends Equatable {
  const _PlayingCategory({
    required this.ageGroup,
    required this.playingLevel,
  });

  final AgeGroup? ageGroup;
  final PlayingLevel? playingLevel;

  _PlayingCategory copyOnly({
    bool ageGroup = false,
    bool playingLevel = false,
  }) {
    return _PlayingCategory(
      ageGroup: ageGroup ? this.ageGroup : null,
      playingLevel: playingLevel ? this.playingLevel : null,
    );
  }

  @override
  List<Object?> get props => [ageGroup, playingLevel];
}
