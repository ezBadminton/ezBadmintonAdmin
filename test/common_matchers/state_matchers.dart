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
