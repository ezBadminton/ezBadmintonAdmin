import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/collection_queries/collection_querier.dart';
import 'package:ez_badminton_admin_app/player_management/models/competition_registration.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ez_badminton_admin_app/player_management/utils/competition_registration.dart'
    as sut;

import '../common_matchers/model_matchers.dart';

class MockCollectionQuerier extends Mock implements CollectionQuerier {}

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
  group('registration mapping', () {
    test('mapCompetitionRegistrations() produces the correct map', () {
      Map<Player, List<CompetitionRegistration>> registrationMap =
          sut.mapCompetitionRegistrations(players, competitions);
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

    test('registrationsOfPlayer() produces the correct list', () {
      List<CompetitionRegistration> registrations0 =
          sut.registrationsOfPlayer(players[0], competitions);

      expect(registrations0, hasLength(1));
      expect(registrations0[0].competition, competitions[0]);

      List<CompetitionRegistration> registrations2 =
          sut.registrationsOfPlayer(players[2], competitions);

      expect(registrations2, hasLength(2));
      expect(registrations2[0].competition, competitions[1]);
      expect(registrations2[1].competition, competitions[2]);

      List<CompetitionRegistration> registrations4 =
          sut.registrationsOfPlayer(players[4], competitions);

      expect(registrations4, isEmpty);
    });
  });

  group('registration update queries', () {
    late CollectionQuerier querier;

    late Competition competition;
    late Player player;
    late Player partner;

    void arrangeCollectionQuerierReturns() {
      when(() => querier.deleteModel<Team>(any()))
          .thenAnswer((_) async => true);

      when(
        () => querier.updateOrCreateModel<Team>(
          any(),
          expand: any(named: 'expand'),
        ),
      ).thenAnswer(
        (invocation) async => invocation.positionalArguments[0] as Team,
      );

      when(
        () => querier.updateModel<Team>(
          any(),
          expand: any(named: 'expand'),
        ),
      ).thenAnswer(
        (invocation) async => invocation.positionalArguments[0] as Team,
      );

      when(
        () => querier.updateModel<Competition>(
          any(),
          expand: any(named: 'expand'),
        ),
      ).thenAnswer(
        (invocation) async => invocation.positionalArguments[0] as Competition,
      );
    }

    void arrangeTeamDeleteErrors() {
      when(() => querier.deleteModel<Team>(any()))
          .thenAnswer((_) async => false);
    }

    void arrangeTeamUpdateOrCreateErrors() {
      when(
        () => querier.updateOrCreateModel<Team>(
          any(),
          expand: any(named: 'expand'),
        ),
      ).thenAnswer((_) async => null);
    }

    void arrangeTeamUpdateErrors() {
      when(
        () => querier.updateModel<Team>(any(), expand: any(named: 'expand')),
      ).thenAnswer((_) async => null);
    }

    void arrangeCompetitionUpdateErrors() {
      when(
        () => querier.updateModel<Competition>(
          any(),
          expand: any(named: 'expand'),
        ),
      ).thenAnswer((_) async => null);
    }

    void arrangePartnerHasSoloTeam() {
      Team soloTeam =
          Team.newTeam(players: [partner]).copyWith(id: 'partner-solo-team');
      competition = competition.copyWith(registrations: [soloTeam]);
    }

    void arrangePartnerHasFullTeam() {
      Team soloTeam = Team.newTeam(players: [partner, Player.newPlayer()])
          .copyWith(id: 'partner-solo-team');
      competition = competition.copyWith(registrations: [soloTeam]);
    }

    void arrangePlayerHasTeam() {
      Team soloTeam = Team.newTeam(players: [player])
          .copyWith(id: 'player-existing-solo-team');
      competition = competition.copyWith(registrations: [soloTeam]);
    }

    void arrangePlayerHasTeamWithPartner() {
      Team partneredTeam = Team.newTeam(players: [player, partner])
          .copyWith(id: 'player-existing-solo-team');
      competition = competition.copyWith(registrations: [partneredTeam]);
    }

    void arrangeCompetitionIsSingles() {
      competition = competition.copyWith(teamSize: 1);
    }

    setUpAll(() {
      registerFallbackValue(Team.newTeam());
      registerFallbackValue(Competition.newCompetition(
        teamSize: 1,
        genderCategory: GenderCategory.any,
      ));
    });

    setUp(() {
      querier = MockCollectionQuerier();
      competition = Competition.newCompetition(
        teamSize: 2,
        genderCategory: GenderCategory.mixed,
      ).copyWith(id: 'test-competition');
      player = Player.newPlayer().copyWith(id: 'test-player');
      partner = Player.newPlayer().copyWith(id: 'test-partner');
      arrangeCollectionQuerierReturns();
    });

    test('solo registration', () async {
      Team soloTeam = Team.newTeam(players: [player]);
      CompetitionRegistration registration = CompetitionRegistration(
        player: player,
        competition: competition,
        team: soloTeam,
      );

      Competition? updatedCompetition =
          await sut.registerCompetition(registration, querier);

      expect(updatedCompetition, isNotNull);
      expect(updatedCompetition!.registrations, hasLength(1));
      expect(updatedCompetition.registrations[0], HasPlayers([player]));

      verify(
        () => querier.updateOrCreateModel<Team>(
          any(that: HasPlayers([player])),
          expand: any(named: 'expand'),
        ),
      ).called(1);
      verify(
        () => querier.updateModel<Competition>(
          any(that: equals(competition)),
          expand: any(named: 'expand'),
        ),
      ).called(1);
      verifyNever(
        () => querier.deleteModel<Team>(any()),
      );
    });

    test('partner registration', () async {
      Team partneredTeam = Team.newTeam(players: [player, partner]);
      CompetitionRegistration registration = CompetitionRegistration(
        player: player,
        competition: competition,
        team: partneredTeam,
      );

      Competition? updatedCompetition =
          await sut.registerCompetition(registration, querier);

      expect(updatedCompetition, isNotNull);
      expect(updatedCompetition!.registrations, hasLength(1));
      expect(
        updatedCompetition.registrations[0],
        HasPlayers([player, partner]),
      );

      verify(
        () => querier.updateOrCreateModel<Team>(
          any(that: HasPlayers([player, partner])),
          expand: any(named: 'expand'),
        ),
      ).called(1);
      verify(
        () => querier.updateModel<Competition>(
          any(that: equals(competition)),
          expand: any(named: 'expand'),
        ),
      ).called(1);
      verifyNever(
        () => querier.deleteModel<Team>(any()),
      );
    });

    test('partner registration, partner has team', () async {
      arrangePartnerHasSoloTeam();
      Team partneredTeam = Team.newTeam(players: [player, partner]);
      CompetitionRegistration registration = CompetitionRegistration(
        player: player,
        competition: competition,
        team: partneredTeam,
      );

      Competition? updatedCompetition =
          await sut.registerCompetition(registration, querier);

      expect(updatedCompetition, isNotNull);
      expect(updatedCompetition!.registrations, hasLength(1));
      expect(
        updatedCompetition.registrations[0],
        HasPlayers([player, partner]),
      );

      verify(
        () => querier.deleteModel<Team>(any(that: HasId('partner-solo-team'))),
      ).called(1);
    });

    test('partner registration, partner already partnered', () async {
      arrangePartnerHasFullTeam();
      Team partneredTeam = Team.newTeam(players: [player, partner]);
      CompetitionRegistration registration = CompetitionRegistration(
        player: player,
        competition: competition,
        team: partneredTeam,
      );

      expect(
        () async => (await sut.registerCompetition(registration, querier)),
        throwsAssertionError,
      );
    });

    test('solo registration, player already registered', () async {
      arrangePlayerHasTeam();
      Team soloTeam = Team.newTeam(players: [player]);
      CompetitionRegistration registration = CompetitionRegistration(
        player: player,
        competition: competition,
        team: soloTeam,
      );

      Competition? updatedCompetition =
          await sut.registerCompetition(registration, querier);

      expect(updatedCompetition, isNull);
    });

    test('partner registration, competition is singles', () async {
      arrangeCompetitionIsSingles();
      Team partneredTeam = Team.newTeam(players: [player, partner]);
      CompetitionRegistration registration = CompetitionRegistration(
        player: player,
        competition: competition,
        team: partneredTeam,
      );

      expect(
        () async => (await sut.registerCompetition(registration, querier)),
        throwsAssertionError,
      );
    });

    test('registration, querier errors', () async {
      arrangePartnerHasSoloTeam();
      Team partneredTeam = Team.newTeam(players: [player, partner]);
      CompetitionRegistration registration = CompetitionRegistration(
        player: player,
        competition: competition,
        team: partneredTeam,
      );

      arrangeTeamDeleteErrors();

      Competition? updatedCompetition =
          await sut.registerCompetition(registration, querier);
      expect(updatedCompetition, isNull);

      arrangeCollectionQuerierReturns();
      arrangeTeamUpdateOrCreateErrors();

      updatedCompetition = await sut.registerCompetition(registration, querier);
      expect(updatedCompetition, isNull);

      arrangeCollectionQuerierReturns();
      arrangeCompetitionUpdateErrors();

      updatedCompetition = await sut.registerCompetition(registration, querier);
      expect(updatedCompetition, isNull);
    });

    test('deregistration, solo team', () async {
      arrangePlayerHasTeam();
      CompetitionRegistration registration =
          CompetitionRegistration.fromCompetition(
        player: player,
        competition: competition,
      );

      Competition? updatedCompetition =
          await sut.deregisterCompetition(registration, querier);

      expect(updatedCompetition, isNotNull);
      expect(updatedCompetition!.registrations, isEmpty);

      verify(
        () => querier.deleteModel<Team>(
          any(that: HasId('player-existing-solo-team')),
        ),
      ).called(1);
      verify(
        () => querier.updateModel<Competition>(
          any(that: HasRegistrations(isEmpty)),
          expand: any(named: 'expand'),
        ),
      ).called(1);
      verifyNever(
        () => querier.updateModel<Team>(any(), expand: any(named: 'expand')),
      );
    });

    test('deregistration, team with partner', () async {
      arrangePlayerHasTeamWithPartner();
      CompetitionRegistration registration =
          CompetitionRegistration.fromCompetition(
        player: player,
        competition: competition,
      );

      Competition? updatedCompetition =
          await sut.deregisterCompetition(registration, querier);

      expect(updatedCompetition, isNotNull);
      expect(updatedCompetition!.registrations, hasLength(1));
      expect(updatedCompetition.registrations[0], HasPlayers([partner]));

      verify(
        () => querier.updateModel<Team>(
          any(that: HasPlayers([partner])),
          expand: any(named: 'expand'),
        ),
      ).called(1);
      verify(
        () => querier.updateModel<Competition>(
          any(that: HasRegistrations(hasLength(1))),
          expand: any(named: 'expand'),
        ),
      ).called(1);
      verifyNever(
        () => querier.deleteModel<Team>(any()),
      );
    });

    test('deregistration, solo team, querier errors', () async {
      arrangePlayerHasTeam();
      CompetitionRegistration registration =
          CompetitionRegistration.fromCompetition(
        player: player,
        competition: competition,
      );

      arrangeTeamDeleteErrors();

      Competition? updatedCompetition =
          await sut.deregisterCompetition(registration, querier);
      expect(updatedCompetition, isNull);

      arrangeCollectionQuerierReturns();
      arrangeCompetitionUpdateErrors();

      updatedCompetition =
          await sut.deregisterCompetition(registration, querier);
      expect(updatedCompetition, isNull);
    });

    test('deregistration, team with partner, querier errors', () async {
      arrangePlayerHasTeamWithPartner();
      CompetitionRegistration registration =
          CompetitionRegistration.fromCompetition(
        player: player,
        competition: competition,
      );

      arrangeTeamUpdateErrors();

      Competition? updatedCompetition =
          await sut.deregisterCompetition(registration, querier);
      expect(updatedCompetition, isNull);

      arrangeCollectionQuerierReturns();
      arrangeCompetitionUpdateErrors();

      updatedCompetition =
          await sut.deregisterCompetition(registration, querier);
      expect(updatedCompetition, isNull);
    });
  });
}
