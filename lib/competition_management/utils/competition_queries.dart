import 'package:collection/collection.dart';
import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/collection_queries/collection_querier.dart';
import 'package:ez_badminton_admin_app/competition_management/models/competition_merge.dart';
import 'package:ez_badminton_admin_app/competition_management/models/playing_category.dart';
import 'package:ez_badminton_admin_app/competition_management/utils/competition_categorization.dart';
import 'package:formz/formz.dart';

abstract mixin class RemovedCategoryCompetitionManagement<
    S extends CollectionFetcherState<S>> {
  S get state;

  CollectionQuerier get querier;

  Future<T?> requestDialogChoice<T>({
    Object reason = const Object(),
  });

  Future<bool> deleteCompetitions(List<Competition> competitions);

  /// Handles the deletion/merging of competitions that are under a category
  /// that is about the be removed.
  ///
  /// The [removedCategory] (of type [AgeGroup] or [PlayingLevel]) itself is not
  /// deleted.
  ///
  /// Dialog inputs are used to ask the user which category to merge the removed
  /// one into if at all.
  Future<FormzSubmissionStatus> manageCompetitionsOfRemovedCategory(
    Model removedCategory,
  ) async {
    assert(removedCategory is AgeGroup || removedCategory is PlayingLevel);

    List<Competition> competitionsOfCategory = _getCompetitionsOfCategory(
      removedCategory,
    );

    // No action on competitions required. When the [removedCategory] was the
    // last one the CompetitionCategorizationCubit will disable AgeGroup
    // categorization and update the competitions accordingly.
    if (competitionsOfCategory.isEmpty || _isLastCategory(removedCategory)) {
      return FormzSubmissionStatus.success;
    }

    List<Team> registrationsInCategory =
        competitionsOfCategory.expand((c) => c.registrations).toList();

    bool userConfirmation;
    Model? replacementCategory;
    if (registrationsInCategory.isEmpty) {
      userConfirmation =
          (await requestDialogChoice<bool>(reason: removedCategory))!;
    } else {
      // Ask user if/where to merge
      replacementCategory = await _askReplacementCategory(removedCategory);
      userConfirmation = replacementCategory != null;
    }
    if (!userConfirmation) {
      return FormzSubmissionStatus.canceled;
    }

    if (replacementCategory != null && replacementCategory.id.isEmpty) {
      replacementCategory = null;
    }

    bool competitionsManaged;
    if (replacementCategory == null) {
      competitionsManaged = await deleteCompetitions(
        _getCompetitionsOfCategory(removedCategory),
      );
    } else {
      competitionsManaged = await _mergeRemovedCategoryCompetitions(
        removedCategory,
        replacementCategory,
      );
    }

    if (!competitionsManaged) {
      return FormzSubmissionStatus.failure;
    }

    return FormzSubmissionStatus.success;
  }

  Future<bool> _mergeRemovedCategoryCompetitions(
    Model removedCategory,
    Model replacementCategory,
  ) async {
    List<Competition> competitionsToMerge = state
        .getCollection<Competition>()
        .where(
          (c) =>
              _isCompetitionInCategory(c, removedCategory) ||
              _isCompetitionInCategory(c, replacementCategory),
        )
        .toList();

    List<List<Competition>> mergeGroups = groupCompetitions(
      competitionsToMerge,
      ignoreAgeGroups: removedCategory is AgeGroup,
      ignorePlayingLevels: removedCategory is PlayingLevel,
    );

    List<CompetitionMerge> merges = mergeGroups.map(
      (mergeGroup) {
        Competition? primaryMerge = mergeGroup.firstWhereOrNull(
          (c) => _isCompetitionInCategory(c, replacementCategory),
        );

        return CompetitionMerge(
          competitions: mergeGroup,
          mergedCategory: _getMergedPlayingCategory(
            mergeGroup,
            replacementCategory,
          ),
          primaryCompetition: primaryMerge,
        );
      },
    ).toList();

    return submitMerges(merges);
  }

  List<Competition> _getCompetitionsOfCategory(Model category) {
    return state
        .getCollection<Competition>()
        .where((c) => _isCompetitionInCategory(c, category))
        .toList();
  }

  bool _isLastCategory(Model category) {
    switch (category) {
      case AgeGroup _:
        return state.getCollection<AgeGroup>().length == 1;
      case PlayingLevel _:
        return state.getCollection<PlayingLevel>().length == 1;
      default:
        return false;
    }
  }

  Future<Model?> _askReplacementCategory(Model removedCategory) async {
    if (removedCategory is AgeGroup) {
      return await requestDialogChoice<AgeGroup>(reason: removedCategory);
    }
    if (removedCategory is PlayingLevel) {
      return await requestDialogChoice<PlayingLevel>(reason: removedCategory);
    }
    return null;
  }

  PlayingCategory _getMergedPlayingCategory(
    List<Competition> mergeGroup,
    Model replacementCategory,
  ) {
    Model? mergeCategory = switch (replacementCategory) {
      AgeGroup _ => mergeGroup.first.playingLevel,
      PlayingLevel _ => mergeGroup.first.ageGroup,
      _ => null,
    };
    if (replacementCategory is AgeGroup) {
      return PlayingCategory(
        ageGroup: replacementCategory,
        playingLevel: mergeCategory as PlayingLevel?,
      );
    }
    if (replacementCategory is PlayingLevel) {
      return PlayingCategory(
        ageGroup: mergeCategory as AgeGroup?,
        playingLevel: replacementCategory,
      );
    }
    return const PlayingCategory(ageGroup: null, playingLevel: null);
  }

  bool _isCompetitionInCategory(Competition competition, Model category) {
    return competition.ageGroup == category ||
        competition.playingLevel == category;
  }

  Future<bool> submitMerge(
    CompetitionMerge merge,
  ) async {
    List<Team> mergedRegistrations = merge.adoptedTeams;

    List<Team?> createdTeams = await querier.createModels(merge.newTeams);
    if (createdTeams.contains(null)) {
      return false;
    }
    mergedRegistrations.addAll(createdTeams.whereType<Team>());

    bool teamsDeleted = await querier.deleteModels(merge.deletedTeams);
    if (!teamsDeleted) {
      return false;
    }

    Competition mergedCompetition = merge.mergedCompetition.copyWith(
      registrations: mergedRegistrations,
    );

    Competition? createdCompetition =
        await querier.updateOrCreateModel(mergedCompetition);
    if (createdCompetition == null) {
      return false;
    }

    List<Competition> mergedCompetitions = List.of(merge.competitions)
      ..remove(merge.primaryCompetition);
    bool competitionsDeleted = await querier.deleteModels(mergedCompetitions);
    if (!competitionsDeleted) {
      return false;
    }

    return true;
  }

  Future<bool> submitMerges(
    List<CompetitionMerge> merges,
  ) async {
    Iterable<Future<bool>> mergeSubmissions =
        merges.map((merge) => submitMerge(merge));

    List<bool> mergesSubmitted = await Future.wait(mergeSubmissions);

    return !mergesSubmitted.contains(false);
  }
}

mixin CompetitionDeletionQueries<S> on CollectionQuerierCubit<S> {
  /// Deletes a [competition] from DB.
  ///
  /// Also deletes all [Team]s that were registered on that competition.
  ///
  /// Resolves to `true` when all deletions were successful.
  Future<bool> deleteCompetition(Competition competition) async {
    bool teamsDeleted = await querier.deleteModels(competition.registrations);
    if (!teamsDeleted) {
      return false;
    }

    bool competitionDeleted = await querier.deleteModel(competition);

    return competitionDeleted;
  }

  /// Deletes multiple [competitions] from DB.
  ///
  /// Also deletes all [Team]s that were registered on those competitions.
  ///
  /// Resolves to `true` when all deletions were successful.
  Future<bool> deleteCompetitions(List<Competition> competitions) async {
    Iterable<Future<bool>> competitionDeletions =
        competitions.map((competition) => deleteCompetition(competition));

    List<bool> competitionsDeleted = await Future.wait(competitionDeletions);

    return !competitionsDeleted.contains(false);
  }
}
