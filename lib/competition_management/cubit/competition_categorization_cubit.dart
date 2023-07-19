import 'package:collection/collection.dart';
import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/collection_queries/collection_querier.dart';
import 'package:ez_badminton_admin_app/competition_management/cubit/competition_categorization_state.dart';
import 'package:ez_badminton_admin_app/competition_management/models/competition_merge.dart';
import 'package:ez_badminton_admin_app/competition_management/models/playing_category.dart';
import 'package:ez_badminton_admin_app/competition_management/utils/competition_categorization.dart';
import 'package:ez_badminton_admin_app/competition_management/utils/competition_queries.dart';
import 'package:ez_badminton_admin_app/widgets/dialog_listener/cubit_mixin/dialog_cubit.dart';
import 'package:ez_badminton_admin_app/widgets/loading_screen/loading_screen.dart';
import 'package:formz/formz.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CompetitionCategorizationCubit
    extends CollectionFetcherCubit<CompetitionCategorizationState>
    with DialogCubit, CompetitionQueries<CompetitionCategorizationState> {
  CompetitionCategorizationCubit({
    required this.l10n,
    required CollectionRepository<Tournament> tournamentRepository,
    required CollectionRepository<Competition> competitionRepository,
    required CollectionRepository<AgeGroup> ageGroupRepository,
    required CollectionRepository<PlayingLevel> playingLevelRepository,
    required CollectionRepository<Team> teamRepository,
  }) : super(
          collectionRepositories: [
            tournamentRepository,
            competitionRepository,
            ageGroupRepository,
            playingLevelRepository,
            teamRepository,
          ],
          CompetitionCategorizationState(),
        ) {
    loadCollections();
    subscribeToCollectionUpdates(
      competitionRepository,
      (_) => loadCollections(),
    );
    subscribeToCollectionUpdates(
      ageGroupRepository,
      (_) => loadCollections(),
    );
    subscribeToCollectionUpdates(
      playingLevelRepository,
      (_) => loadCollections(),
    );
  }

  final AppLocalizations l10n;

  void loadCollections() {
    if (state.loadingStatus != LoadingStatus.loading) {
      emit(state.copyWith(loadingStatus: LoadingStatus.loading));
    }
    fetchCollectionsAndUpdateState(
      [
        collectionFetcher<Tournament>(),
        collectionFetcher<Competition>(),
        collectionFetcher<AgeGroup>(),
        collectionFetcher<PlayingLevel>(),
      ],
      onSuccess: (updatedState) {
        emit(updatedState.copyWith(loadingStatus: LoadingStatus.done));

        if (state.tournament.useAgeGroups &&
            updatedState.getCollection<AgeGroup>().isEmpty) {
          useAgeGroupsChanged(false);
        }
        if (state.tournament.usePlayingLevels &&
            updatedState.getCollection<PlayingLevel>().isEmpty) {
          usePlayingLevelsChanged(false);
        }
      },
      onFailure: () {
        emit(state.copyWith(loadingStatus: LoadingStatus.failed));
      },
    );
  }

  void useAgeGroupsChanged(bool useAgeGroups) {
    Tournament updatedTournament = state.tournament.copyWith(
      useAgeGroups: useAgeGroups,
    );
    _updateTournament(updatedTournament);
  }

  void usePlayingLevelsChanged(bool usePlayingLevels) {
    Tournament updatedTournament = state.tournament.copyWith(
      usePlayingLevels: usePlayingLevels,
    );
    _updateTournament(updatedTournament);
  }

  /// Updates any existing competitions when the tournament's categorization
  /// options change
  Future<bool> _updateExistingCompetitions(Tournament updatedTournament) async {
    List<Competition> competitionCollection =
        state.getCollection<Competition>();

    if (competitionCollection.isEmpty) {
      return true;
    }

    bool ageGroupsUpdated = true;
    if (!state.tournament.useAgeGroups && updatedTournament.useAgeGroups) {
      ageGroupsUpdated = await _setDefaultAgeGroup();
    } else if (state.tournament.useAgeGroups &&
        !updatedTournament.useAgeGroups) {
      ageGroupsUpdated = await _disableCompetitionAgeGroups();
    }
    if (!ageGroupsUpdated) {
      return false;
    }

    bool playingLevelsUpdated = true;
    if (!state.tournament.usePlayingLevels &&
        updatedTournament.usePlayingLevels) {
      playingLevelsUpdated = await _setDefaultPlayingLevel();
    } else if (state.tournament.usePlayingLevels &&
        !updatedTournament.usePlayingLevels) {
      playingLevelsUpdated = await _disableCompetitionPlayingLevels();
    }
    if (!playingLevelsUpdated) {
      return false;
    }

    return true;
  }

  Future<bool> _setDefaultAgeGroup() async {
    List<AgeGroup> ageGroupCollection = state.getCollection<AgeGroup>();

    AgeGroup? defaultAgeGroup = ageGroupCollection.firstOrNull;
    if (defaultAgeGroup == null) {
      defaultAgeGroup = await _createDefaultAgeGroup();
      if (defaultAgeGroup == null) {
        return false;
      }
    }

    List<Competition> defaultAgeGroupCompetitions = state
        .getCollection<Competition>()
        .map((c) => c.copyWith(ageGroup: defaultAgeGroup))
        .toList();

    List<Competition?> updatedCompetitions = await querier.updateModels(
      defaultAgeGroupCompetitions,
    );

    return !updatedCompetitions.contains(null);
  }

  Future<bool> _disableCompetitionAgeGroups() async {
    Map<AgeGroup, List<Competition>> ageGroupedCompetitions =
        state.getCollection<Competition>().groupListsBy((c) => c.ageGroup!);

    Map<AgeGroup, int> registrationCounts = ageGroupedCompetitions.map(
      (ageGroups, competitions) => MapEntry<AgeGroup, int>(
        ageGroups,
        competitions.fold(
          0,
          (previousValue, element) =>
              previousValue + element.registrations.length,
        ),
      ),
    );

    // If more than one AgeGroup contains registrations, the user is warned
    // of the subsequent merging of registrations by merging of the AgeGroups.
    bool doRegistrationsMerge = registrationCounts.values
            .where((registrationCount) => registrationCount > 0)
            .length >
        1;

    if (doRegistrationsMerge) {
      bool mergingConfirmed = (await requestDialogChoice<bool>(
        reason: CategoryMergeType.ageGroupMerge,
      ))!;
      if (!mergingConfirmed) {
        return false;
      }
    }

    bool competitionsMerged = await _mergeCompetitions(mergeAgeGroups: true);
    if (!competitionsMerged) {
      return false;
    }

    return true;
  }

  Future<bool> _setDefaultPlayingLevel() async {
    List<PlayingLevel> playingLevelCollection =
        state.getCollection<PlayingLevel>();

    PlayingLevel? defaultPlayingLevel = playingLevelCollection
        .firstWhereOrNull((lvl) => lvl.name == l10n.defaultPlayingLevel);
    if (defaultPlayingLevel == null) {
      defaultPlayingLevel = await _createDefaultPlayingLevel();
      if (defaultPlayingLevel == null) {
        return false;
      }
    }

    List<Competition> defaultPlayingLevelCompetitions = state
        .getCollection<Competition>()
        .map((c) => c.copyWith(playingLevel: defaultPlayingLevel))
        .toList();

    List<Competition?> updatedCompetitions =
        await querier.updateModels(defaultPlayingLevelCompetitions);

    return !updatedCompetitions.contains(null);
  }

  Future<bool> _disableCompetitionPlayingLevels() async {
    Map<PlayingLevel, List<Competition>> playingLevelCompetitions =
        state.getCollection<Competition>().groupListsBy((c) => c.playingLevel!);

    Map<PlayingLevel, int> registrationCounts = playingLevelCompetitions.map(
      (playingLevels, competitions) => MapEntry<PlayingLevel, int>(
        playingLevels,
        competitions.fold(
          0,
          (previousValue, element) =>
              previousValue + element.registrations.length,
        ),
      ),
    );

    // If more than one AgeGroup contains registrations, the user is warned
    // of the subsequent merging of registrations by merging of the AgeGroups.
    bool doRegistrationsMerge = registrationCounts.values
            .where((registrationCount) => registrationCount > 0)
            .length >
        1;

    if (doRegistrationsMerge) {
      bool mergingConfirmed = (await requestDialogChoice<bool>(
        reason: CategoryMergeType.playingLevelMerge,
      ))!;
      if (!mergingConfirmed) {
        return false;
      }
    }

    bool competitionsMerged =
        await _mergeCompetitions(mergePlayingLevels: true);
    if (!competitionsMerged) {
      return false;
    }

    return true;
  }

  Future<bool> _mergeCompetitions({
    bool mergeAgeGroups = false,
    bool mergePlayingLevels = false,
  }) async {
    List<List<Competition>> competitionsToMerge = groupCompetitions(
      state.getCollection<Competition>(),
      ignoreAgeGroups: mergeAgeGroups,
      ignorePlayingLevels: mergePlayingLevels,
    );

    List<CompetitionMerge> merges = competitionsToMerge
        .map(
          (competitions) => CompetitionMerge(
            competitions: competitions,
            mergedCategory: PlayingCategory.fromCompetition(
              competitions.first,
              ignoreAgeGroup: mergeAgeGroups,
              ignorePlayingLevel: mergePlayingLevels,
            ),
          ),
        )
        .toList();

    bool mergesSubmitted = await submitMerges(merges);
    if (!mergesSubmitted) {
      return false;
    }

    return true;
  }

  Future<AgeGroup?> _createDefaultAgeGroup() async {
    AgeGroup defaultAgeGroup = AgeGroup.newAgeGroup(
      type: AgeGroupType.under,
      age: 99,
    );

    return querier.createModel(defaultAgeGroup);
  }

  Future<PlayingLevel?> _createDefaultPlayingLevel() async {
    PlayingLevel defaultPlayingLevel = PlayingLevel.newPlayingLevel(
      l10n.defaultPlayingLevel,
      state.getCollection<PlayingLevel>().length,
    );

    return querier.createModel(defaultPlayingLevel);
  }

  void _updateTournament(Tournament updatedTournament) async {
    if (state.formStatus == FormzSubmissionStatus.inProgress) {
      return;
    }
    emit(state.copyWith(formStatus: FormzSubmissionStatus.inProgress));

    bool competitionsUpdated =
        await _updateExistingCompetitions(updatedTournament);
    if (!competitionsUpdated) {
      emit(state.copyWith(formStatus: FormzSubmissionStatus.failure));
      return;
    }

    Tournament? updatedTournamentFromDB =
        await querier.updateModel(updatedTournament);
    if (updatedTournamentFromDB == null) {
      emit(state.copyWith(formStatus: FormzSubmissionStatus.failure));
      return;
    }
    CompetitionCategorizationState updatedState = state.copyWithCollection(
      modelType: Tournament,
      collection: [updatedTournamentFromDB],
    );
    emit(updatedState.copyWith(
      formStatus: FormzSubmissionStatus.success,
    ));
  }
}

enum CategoryMergeType { ageGroupMerge, playingLevelMerge }
