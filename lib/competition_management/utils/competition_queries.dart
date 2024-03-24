import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/collection_queries/collection_querier.dart';
import 'package:formz/formz.dart';

abstract mixin class RemovedCategoryCompetitionManagement<
    S extends CollectionQuerierState> {
  S get state;

  CollectionQuerier get querier;

  Future<T?> requestDialogChoice<T>({
    Object reason = const Object(),
  });

  /// When the [removedCategory] is about to be deleted this method sends dialog
  /// requests asking for confirmation and offering the option to merge the
  /// deleted category's registrations with another category.
  ///
  /// The return record contains [FormzSubmissionStatus.canceled] in case
  /// the use chose to cancel the entire deletion and optionally a
  /// [PlayingLevel] or [AgeGroup] model that the user chose as the replacement.
  Future<(FormzSubmissionStatus, Model?)> askForReplacementCategory(
    Model removedCategory,
  ) async {
    assert(removedCategory is AgeGroup || removedCategory is PlayingLevel);

    List<Competition> competitionsOfCategory = _getCompetitionsOfCategory(
      removedCategory,
    );

    // No action on competitions required. When the [removedCategory] was the
    // last one the categorization will be disabled.
    if (competitionsOfCategory.isEmpty || _isLastCategory(removedCategory)) {
      return (FormzSubmissionStatus.success, null);
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
      return (FormzSubmissionStatus.canceled, null);
    }

    if (replacementCategory != null && replacementCategory.id.isEmpty) {
      replacementCategory = null;
    }

    return (FormzSubmissionStatus.success, replacementCategory);
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

  bool _isCompetitionInCategory(Competition competition, Model category) {
    return competition.ageGroup == category ||
        competition.playingLevel == category;
  }
}
