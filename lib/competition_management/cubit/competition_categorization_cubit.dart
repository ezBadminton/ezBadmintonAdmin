import 'package:collection/collection.dart';
import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/collection_queries/collection_querier.dart';
import 'package:ez_badminton_admin_app/competition_management/cubit/competition_categorization_state.dart';
import 'package:ez_badminton_admin_app/competition_management/models/competition_merge.dart';
import 'package:ez_badminton_admin_app/competition_management/models/playing_category.dart';
import 'package:ez_badminton_admin_app/competition_management/utils/competition_categorization.dart';
import 'package:ez_badminton_admin_app/widgets/confirm_dialog/cubit_mixin/dialog_cubit.dart';
import 'package:ez_badminton_admin_app/widgets/loading_screen/loading_screen.dart';
import 'package:formz/formz.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CompetitionCategorizationCubit
    extends CollectionFetcherCubit<CompetitionCategorizationState>
    with DialogCubit<CompetitionCategorizationState> {
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
      ageGroupsUpdated = await _enableCompetitionAgeGroups();
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
      playingLevelsUpdated = await _enableCompetitionPlayingLevels();
    } else if (state.tournament.usePlayingLevels &&
        !updatedTournament.usePlayingLevels) {
      playingLevelsUpdated = await _disableCompetitionPlayingLevels();
    }
    if (!playingLevelsUpdated) {
      return false;
    }

    return true;
  }

  Future<bool> _enableCompetitionAgeGroups() async {
    List<AgeGroup> ageGroupCollection = state.getCollection<AgeGroup>();

    AgeGroup? defaultAgeGroup = ageGroupCollection.firstOrNull;
    if (defaultAgeGroup == null) {
      defaultAgeGroup = await _createDefaultAgeGroup();
      if (defaultAgeGroup == null) {
        return false;
      }
    }

    Iterable<Future<Competition?>> competitionUpdates = state
        .getCollection<Competition>()
        .map((c) => c.copyWith(ageGroup: defaultAgeGroup))
        .map((c) => querier.updateModel(c));

    List<Competition?> updatedCompetitions =
        await Future.wait(competitionUpdates);

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
      bool mergingConfirmed = (await requestDialogConfirmation(
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
      bool mergingConfirmed = (await requestDialogConfirmation(
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

    Iterable<Future<bool>> mergeSubmissions =
        merges.map((merge) => _submitMerge(merge));
    List<bool> mergesSubmitted = await Future.wait(mergeSubmissions);
    if (mergesSubmitted.contains(false)) {
      return false;
    }

    return true;
  }

  Future<bool> _submitMerge(CompetitionMerge merge) async {
    List<Team> mergedRegistrations = merge.adoptedTeams;

    Iterable<Future<Team?>> teamCreations =
        merge.newTeams.map((team) => querier.createModel(team));
    List<Team?> createdTeams = await Future.wait(teamCreations);
    if (createdTeams.contains(null)) {
      return false;
    }
    mergedRegistrations.addAll(createdTeams.whereType<Team>());

    Iterable<Future<bool>> teamDeletions =
        merge.deletedTeams.map((team) => querier.deleteModel(team));
    List<bool> teamsDeleted = await Future.wait(teamDeletions);
    if (teamsDeleted.contains(false)) {
      return false;
    }

    Competition mergedCompetition = merge.mergedCompetition.copyWith(
      registrations: mergedRegistrations,
    );
    Competition? createdCompetition =
        await querier.createModel(mergedCompetition);
    if (createdCompetition == null) {
      return false;
    }

    Iterable<Future<bool>> competitionDeletions = merge.competitions
        .map((competition) => querier.deleteModel(competition));
    List<bool> competitionsDeleted = await Future.wait(competitionDeletions);
    if (competitionsDeleted.contains(false)) {
      return false;
    }

    return true;
  }

  Future<bool> _enableCompetitionPlayingLevels() async {
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

    Iterable<Future<Competition?>> competitionUpdates = state
        .getCollection<Competition>()
        .map((c) => c.copyWith(playingLevel: defaultPlayingLevel))
        .map((c) => querier.updateModel(c));

    List<Competition?> updatedCompetitions =
        await Future.wait(competitionUpdates);

    return !updatedCompetitions.contains(null);
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
