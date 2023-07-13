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

    List<_PlayingCategory> possibleCategories = [
      for (AgeGroup? ageGroup in ageGroups)
        for (PlayingLevel? playingLevel in playingLevels)
          _PlayingCategory(ageGroup: ageGroup, playingLevel: playingLevel),
    ];

    Map<_PlayingCategory, List<CompetitionCategory>>
        existingCategorizedBaseCompetitions = {
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
            !existingCategorizedBaseCompetitions[playingCategory]!
                .contains(competitionCategory),
          );

          existingCategorizedBaseCompetitions[playingCategory]!
              .add(competitionCategory);
        }
      }
    }

    Map<CompetitionCategory, List<_PlayingCategory>>
        existingPlayingCategoriesInBaseCompetitions = {
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
              (c) => existingPlayingCategoriesInBaseCompetitions[
                      competitionCategory]!
                  .contains(c),
            )
            .contains(true),
      );

      existingPlayingCategoriesInBaseCompetitions[competitionCategory]!
          .addAll(playingCategories);
    }

    List<_PlayingCategory> creatableCategories = possibleCategories
        .where(
          (category) =>
              existingCategorizedBaseCompetitions[category]!.length <
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
                  existingPlayingCategoriesInBaseCompetitions[baseCompetition]!
                      .length <
                  possibleCategories.length,
            )
            .toSet();

    for (AgeGroup selectedAgeGroup in state.ageGroups) {
      Iterable<MapEntry<_PlayingCategory, List<CompetitionCategory>>>
          categoriesOfSelection = existingCategorizedBaseCompetitions.entries
              .where((entry) => entry.key.ageGroup == selectedAgeGroup);
      for (MapEntry<_PlayingCategory,
              List<CompetitionCategory>> categorizedBaseCompetitions
          in categoriesOfSelection) {
        if (categorizedBaseCompetitions.value.length ==
            CompetitionCategory.defaultCompetitions.length) {
          creatablePlayingLevels.remove(
            categorizedBaseCompetitions.key.playingLevel,
          );
        }
      }
    }

    for (PlayingLevel selectedPlayingLevel in state.playingLevels) {
      Iterable<MapEntry<_PlayingCategory, List<CompetitionCategory>>>
          categoriesOfSelection = existingCategorizedBaseCompetitions.entries
              .where((entry) => entry.key.playingLevel == selectedPlayingLevel);
      for (MapEntry<_PlayingCategory,
              List<CompetitionCategory>> categorizedBaseCompetitions
          in categoriesOfSelection) {
        if (categorizedBaseCompetitions.value.length ==
            CompetitionCategory.defaultCompetitions.length) {
          creatableAgeGroups.remove(
            categorizedBaseCompetitions.key.ageGroup,
          );
        }
      }
    }

    if ((useAgeGroups || usePlayingLevels) &&
        useAgeGroups == state.ageGroups.isNotEmpty &&
        usePlayingLevels == state.playingLevels.isNotEmpty) {
      List<AgeGroup?> selectedAgeGroups =
          state.ageGroups.isEmpty ? [null] : state.ageGroups;
      List<PlayingLevel?> selectedPlayingLevels =
          state.playingLevels.isEmpty ? [null] : state.playingLevels;

      for (AgeGroup? ageGroup in selectedAgeGroups) {
        for (PlayingLevel? playingLevel in selectedPlayingLevels) {
          var playingCategory = _PlayingCategory(
            ageGroup: ageGroup,
            playingLevel: playingLevel,
          );
          creatableBaseCompetitions.removeAll(
            existingCategorizedBaseCompetitions[playingCategory]!,
          );
        }
      }
    }

    Set<CompetitionCategory> disabledBaseCompetitions =
        CompetitionCategory.defaultCompetitions
            .whereNot(
              (baseCompetition) =>
                  creatableBaseCompetitions.contains(baseCompetition),
            )
            .toSet();

    Set<AgeGroup> disabledAgeGroups = ageGroups
        .whereNot(
          (ageGroup) => creatableAgeGroups.contains(ageGroup),
        )
        .whereType<AgeGroup>()
        .toSet();

    Set<PlayingLevel> disabledPlayingLevels = playingLevels
        .whereNot(
          (playingLevel) => creatablePlayingLevels.contains(playingLevel),
        )
        .whereType<PlayingLevel>()
        .toSet();

    var newState = state.copyWith(
      disabledCompetitionCategories: disabledBaseCompetitions,
      disabledAgeGroups: disabledAgeGroups,
      disabledPlayingLevels: disabledPlayingLevels,
    );
    newState = _unselectDisabledOptions(newState);

    return newState;
  }

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
}

class _PlayingCategory extends Equatable {
  /// A tuple of [ageGroup] and [playingLevel] forming a playing category.
  ///
  /// [ageGroup] and [playingLevel] can be null when the current [Tournament]
  /// does not use these categorizations.
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
