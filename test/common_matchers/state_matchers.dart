import 'package:collection_repository/collection_repository.dart';
import 'package:flutter_test/flutter_test.dart';

class HasLoadingStatus extends CustomMatcher {
  HasLoadingStatus(matcher)
      : super(
          'State with',
          'LoadingStatus',
          matcher,
        );
  @override
  featureValueOf(actual) => actual.loadingStatus;
}

class HasFormStatus extends CustomMatcher {
  HasFormStatus(matcher)
      : super(
          'State with',
          'FormzSubmissionStatus',
          matcher,
        );
  @override
  featureValueOf(actual) => actual.formStatus;
}

class HasPlayer extends CustomMatcher {
  HasPlayer(matcher)
      : super(
          'State with Player that is',
          'Player',
          matcher,
        );
  @override
  featureValueOf(actual) => actual.player;
}

class HasFirstNameInput extends CustomMatcher {
  HasFirstNameInput(matcher)
      : super(
          'State with first name input value of',
          'first name',
          matcher,
        );
  @override
  featureValueOf(actual) => actual.firstName.value;
}

class HasLastNameInput extends CustomMatcher {
  HasLastNameInput(matcher)
      : super(
          'State with last name input value of',
          'first name',
          matcher,
        );
  @override
  featureValueOf(actual) => actual.lastName.value;
}

class HasClubNameInput extends CustomMatcher {
  HasClubNameInput(matcher)
      : super(
          'State with club name input value of',
          'club name',
          matcher,
        );
  @override
  featureValueOf(actual) => actual.clubName.value;
}

class HasEMailInput extends CustomMatcher {
  HasEMailInput(matcher)
      : super(
          'State with eMail input value of',
          'eMail',
          matcher,
        );
  @override
  featureValueOf(actual) => actual.eMail.value;
}

class HasNotesInput extends CustomMatcher {
  HasNotesInput(matcher)
      : super(
          'State with notes input value of',
          'notes',
          matcher,
        );
  @override
  featureValueOf(actual) => actual.notes.value;
}

class HasDateOfBirthInput extends CustomMatcher {
  HasDateOfBirthInput(matcher)
      : super(
          'State with date of birth string input value of',
          'date of birth string',
          matcher,
        );
  @override
  featureValueOf(actual) => actual.dateOfBirth.value;
}

class HasPlayingLevelInput extends CustomMatcher {
  HasPlayingLevelInput(matcher)
      : super(
          'State with playing level input value of',
          'PlayingLevel',
          matcher,
        );
  @override
  featureValueOf(actual) => actual.playingLevel.value;
}

class HasAgeGroupInput extends CustomMatcher {
  HasAgeGroupInput(matcher)
      : super(
          'State with age group input value of',
          'AgeGroup',
          matcher,
        );
  @override
  featureValueOf(actual) => actual.ageGroup.value;
}

class HasGenderCategoryInput extends CustomMatcher {
  HasGenderCategoryInput(matcher)
      : super(
          'State with gender category input value of',
          'GenderCategory',
          matcher,
        );
  @override
  featureValueOf(actual) => actual.genderCategory.value;
}

class HasCompetitionTypeInput extends CustomMatcher {
  HasCompetitionTypeInput(matcher)
      : super(
          'State with competition type input value of',
          'CompetitionType',
          matcher,
        );
  @override
  featureValueOf(actual) => actual.competitionType.value;
}

class HasCollection<M extends Model> extends CustomMatcher {
  HasCollection(matcher)
      : super(
          'State with collection',
          'collection of models',
          matcher,
        );
  @override
  featureValueOf(actual) => actual.getCollection<M>();
}

class HasComparator extends CustomMatcher {
  HasComparator(matcher)
      : super(
          'State with sorting comparator',
          'ListSortingComparator',
          matcher,
        );
  @override
  featureValueOf(actual) => actual.sortingComparator;
}

class HasDialog extends CustomMatcher {
  HasDialog(matcher)
      : super(
          'DialogState with dialog',
          'CubitDialog',
          matcher,
        );
  @override
  featureValueOf(actual) => actual.dialog;
}

class HasDialogCompleter extends CustomMatcher {
  HasDialogCompleter(matcher)
      : super(
          'CubitDialog with decisionCompleter',
          'Completer',
          matcher,
        );
  @override
  featureValueOf(actual) => actual.decisionCompleter;
}

class IsComplete extends CustomMatcher {
  IsComplete(matcher)
      : super(
          'A Completer with completion',
          'bool',
          matcher,
        );
  @override
  featureValueOf(actual) => actual.isCompleted;
}

class HasDialogReason extends CustomMatcher {
  HasDialogReason(matcher)
      : super(
          'CubitDialog with reason',
          'Object',
          matcher,
        );
  @override
  featureValueOf(actual) => actual.reason;
}

class IsFormSubmittable extends CustomMatcher {
  IsFormSubmittable(matcher)
      : super(
          'State that is submittable',
          'bool',
          matcher,
        );
  @override
  featureValueOf(actual) => actual.formSubmittable;
}

class HasSelectedCompetitions extends CustomMatcher {
  HasSelectedCompetitions(matcher)
      : super(
          'State with selected competitions',
          'List of Competitions',
          matcher,
        );
  @override
  featureValueOf(actual) => actual.selectedCompetitions;
}

class HasFilterPredicate extends CustomMatcher {
  HasFilterPredicate(matcher)
      : super(
          'State with a FilterPredicate that is',
          'FilterPredicate',
          matcher,
        );
  @override
  featureValueOf(actual) => actual.filterPredicate;
}
