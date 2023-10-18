import 'package:collection_repository/collection_repository.dart';
import 'package:collection_repository/src/expansion_tree/expanded_field.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late ExpansionTree sut;

  List<ExpandedField> rootFields = [
    const ExpandedField(
      model: AgeGroup,
      key: 'ageGroups',
      isRequired: true,
      isSingle: false,
    ),
    const ExpandedField(
      model: PlayingLevel,
      key: 'playingLevel',
      isRequired: false,
      isSingle: true,
    ),
    const ExpandedField(
      model: Team,
      key: 'registrations',
      isRequired: true,
      isSingle: false,
    ),
  ];

  List<ExpandedField> teamFields = [
    const ExpandedField(
      model: Player,
      key: 'players',
      isRequired: true,
      isSingle: false,
    ),
  ];

  List<ExpandedField> playerFields = [
    const ExpandedField(
      model: PlayingLevel,
      key: 'playingLevel',
      isRequired: false,
      isSingle: true,
    ),
    const ExpandedField(
      model: Club,
      key: 'club',
      isRequired: false,
      isSingle: true,
    ),
  ];

  List<ExpandedField> ageGroupExpansions = [
    const ExpandedField(
      model: MatchData,
      key: 'match',
      isRequired: false,
      isSingle: true,
    ),
  ];

  setUp(() {
    sut = ExpansionTree(rootFields);
  });

  test('empty ExpansionTree leads to empty expandString', () {
    expect(ExpansionTree([]).expandString, '');
  });

  test('root fields create correct expand string', () {
    var expandString = sut.expandString;
    expect(expandString, 'ageGroups,playingLevel,registrations');
  });

  test('1st level expansions create correct expand string', () {
    var expandString = (sut..expandWith(Team, teamFields)).expandString;
    expect(expandString, 'ageGroups,playingLevel,registrations.players');
  });

  test('2nd level expansions create correct expand string', () {
    var expandString = (sut
          ..expandWith(Team, teamFields)
          ..expandWith(Player, playerFields))
        .expandString;
    expect(
      expandString,
      'ageGroups,playingLevel,registrations.players.playingLevel,registrations.players.club',
    );
  });

  test('expansions to levels other than the deepest are possible', () {
    var expandString = (sut
          ..expandWith(Team, teamFields)
          ..expandWith(Player, playerFields)
          ..expandWith(AgeGroup, ageGroupExpansions))
        .expandString;
    expect(
      expandString,
      'ageGroups.match,playingLevel,registrations.players.playingLevel,registrations.players.club',
    );
  });
}
