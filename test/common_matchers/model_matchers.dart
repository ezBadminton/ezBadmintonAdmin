import 'package:flutter_test/flutter_test.dart';

class HasId extends CustomMatcher {
  HasId(matcher)
      : super(
          'Model with ID',
          'ID',
          matcher,
        );
  @override
  featureValueOf(actual) => actual.id;
}

class HasFirstName extends CustomMatcher {
  HasFirstName(matcher)
      : super(
          'Player with first name',
          'first name',
          matcher,
        );
  @override
  featureValueOf(actual) => actual.firstName;
}

class HasLastName extends CustomMatcher {
  HasLastName(matcher)
      : super(
          'Player with last name',
          'first name',
          matcher,
        );
  @override
  featureValueOf(actual) => actual.lastName;
}

class HasClub extends CustomMatcher {
  HasClub(matcher)
      : super(
          'Player with club',
          'Club',
          matcher,
        );
  @override
  featureValueOf(actual) => actual.club;
}

class HasNotes extends CustomMatcher {
  HasNotes(matcher)
      : super(
          'Player with notes of',
          'notes',
          matcher,
        );
  @override
  featureValueOf(actual) => actual.notes;
}

class HasDateOfBirth extends CustomMatcher {
  HasDateOfBirth(matcher)
      : super(
          'Player with date of birth of',
          'date of birth',
          matcher,
        );
  @override
  featureValueOf(actual) => actual.dateOfBirth;
}

class HasStatus extends CustomMatcher {
  HasStatus(matcher)
      : super(
          'Player with status of',
          'PlayerStatus',
          matcher,
        );
  @override
  featureValueOf(actual) => actual.status;
}

class HasPlayingLevel extends CustomMatcher {
  HasPlayingLevel(matcher)
      : super(
          'Model with playing level of',
          'PlayingLevel',
          matcher,
        );
  @override
  featureValueOf(actual) => actual.playingLevel;
}

class HasAgeGroup extends CustomMatcher {
  HasAgeGroup(matcher)
      : super(
          'Model with age group of',
          'AgeGroup',
          matcher,
        );
  @override
  featureValueOf(actual) => actual.ageGroup;
}

class HasName extends CustomMatcher {
  HasName(matcher)
      : super(
          'Model with name of',
          'name string',
          matcher,
        );
  @override
  featureValueOf(actual) => actual.name;
}

class HasIndex extends CustomMatcher {
  HasIndex(matcher)
      : super(
          'Model with index of',
          'int',
          matcher,
        );
  @override
  featureValueOf(actual) => actual.index;
}

class HasPlayers extends CustomMatcher {
  HasPlayers(matcher)
      : super(
          'Team with player',
          'Player list',
          matcher,
        );
  @override
  featureValueOf(actual) => actual.players;
}

class HasRegistrations extends CustomMatcher {
  HasRegistrations(matcher)
      : super(
          'Competition with registrations',
          'Team list',
          matcher,
        );
  @override
  featureValueOf(actual) => actual.registrations;
}

class HasAgeGroupCategorization extends CustomMatcher {
  HasAgeGroupCategorization(matcher)
      : super(
          'Tournament using age groups',
          'bool',
          matcher,
        );
  @override
  featureValueOf(actual) => actual.useAgeGroups;
}

class HasPlayingLevelCategorization extends CustomMatcher {
  HasPlayingLevelCategorization(matcher)
      : super(
          'Tournament using playing levels',
          'bool',
          matcher,
        );
  @override
  featureValueOf(actual) => actual.usePlayingLevels;
}

class HasAgeGroupType extends CustomMatcher {
  HasAgeGroupType(matcher)
      : super(
          'AgeGroup with',
          'AgeGroupType',
          matcher,
        );
  @override
  featureValueOf(actual) => actual.type;
}

class HasAge extends CustomMatcher {
  HasAge(matcher)
      : super(
          'Model with age of',
          'int',
          matcher,
        );
  @override
  featureValueOf(actual) => actual.age;
}
