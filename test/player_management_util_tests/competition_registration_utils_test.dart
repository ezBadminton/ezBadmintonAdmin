import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/player_management/utils/competition_registration.dart';
import 'package:flutter_test/flutter_test.dart';

var players = ['0', '1', '2', '3', '4']
    .map(
      (id) => Player.newPlayer().copyWith(id: id),
    )
    .toList();

var competitions = {
  'a': ['0'],
  'b': ['1', '2'],
  'c': ['2', '3'],
}.entries.map((registration) {
  var id = registration.key;
  var registrations = players
      .where((p) => registration.value.contains(p.id))
      .map((p) => Team.newTeam(players: [p]))
      .toList();
  return Competition.newCompetition(
    teamSize: 1,
    genderCategory: GenderCategory.any,
  ).copyWith(id: id, registrations: registrations);
}).toList();

void main() {
  test('mapCompetitionRegistrations() produces the correct map', () {
    var registrationMap = mapCompetitionRegistrations(players, competitions);
    expect(registrationMap.length, players.length);
    expect(registrationMap[players[0]], hasLength(1));
    expect(registrationMap[players[0]]![0].team.players, [players[0]]);
    expect(registrationMap[players[0]]![0].competition, competitions[0]);

    expect(
      registrationMap[players[1]]!.map((r) => r.competition).toList(),
      [competitions[1]],
    );
    expect(
      registrationMap[players[2]]!.map((r) => r.competition).toList(),
      [competitions[1], competitions[2]],
    );
    expect(
      registrationMap[players[3]]!.map((r) => r.competition).toList(),
      [competitions[2]],
    );
    expect(
      registrationMap[players[4]]!.map((r) => r.competition).toList(),
      [],
    );
  });
}
