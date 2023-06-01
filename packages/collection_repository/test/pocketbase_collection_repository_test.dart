import 'package:collection_repository/collection_repository.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:pocketbase_provider/pocketbase_provider.dart';
import 'package:flutter_test/flutter_test.dart';

class MockPocketBaseProvider extends Mock implements PocketBaseProvider {}

class MockPocketBase extends Mock implements PocketBase {}

class MockRecordService extends Mock implements RecordService {}

void main() {
  late PocketbaseCollectionRepository<Player> sut;
  late MockPocketBaseProvider pocketBaseProvider;
  late MockPocketBase pocketBase;
  late MockRecordService playerRecordService;

  setUp(() {
    pocketBaseProvider = MockPocketBaseProvider();
    pocketBase = MockPocketBase();
    playerRecordService = MockRecordService();
    when(() => pocketBaseProvider.pocketBase).thenReturn(pocketBase);
    when(() => pocketBase.collection('players'))
        .thenReturn(playerRecordService);
    sut = PocketbaseCollectionRepository(
      modelConstructor: Player.fromJson,
      pocketBaseProvider: pocketBaseProvider,
    );
  });

  group(
    'Fetching data',
    () {
      final playersFromPocketBase = <Map<String, dynamic>>[
        {
          // Miniumum required fields for Player
          'id': 'idn5ie3jln40n71',
          'created': '2023-05-18T12:14:24.274',
          'updated': '2023-05-18T12:14:24.274',
          'firstName': 'Akane',
          'lastName': 'Yamaguchi',
        },
        {
          // All non-relation fields for Player
          'id': 'jsi7rtn1mo054da',
          'created': '2023-05-18T12:14:24.274',
          'updated': '2023-05-18T12:14:24.274',
          'firstName': 'Viktor',
          'lastName': 'Axelsen',
          'gender': 'male',
          'dateOfBirth': '1994-01-04T00:00:00.000',
          'eMail': 'player@example.com',
        },
        {
          // Some fields set as empty
          // (pocketbase sends null fields as empty strings)
          'id': '7fn2hj0m1n48s5x',
          'created': '2023-05-18T12:14:24.274',
          'updated': '2023-05-18T12:14:24.274',
          'firstName': 'He',
          'lastName': 'Bingjiao',
          'gender': 'female',
          'dateOfBirth': '',
          'eMail': '',
        },
        {
          // Player with relations
          'id': '7fn2hj0m1n48s5x',
          'created': '2023-05-18T12:14:24.274',
          'updated': '2023-05-18T12:14:24.274',
          'firstName': 'Lee',
          'lastName': 'Chong Wei',
          'gender': 'male',
          'playingLevel': 'relatedfield123',
        },
      ];

      final playingLevelFromPocketBase = <String, dynamic>{
        'id': 'relatedfield123',
        'created': '2023-05-18T12:14:24.274',
        'updated': '2023-05-18T12:14:24.274',
        'index': 0,
        'name': 'very good player',
      };

      void arrangePocketBaseReturnsPlayers() {
        when(
          () => playerRecordService.getFullList(expand: any(named: 'expand')),
        ).thenAnswer(
          (_) async {
            return playersFromPocketBase
                .map((json) => RecordModel(data: json))
                .toList();
          },
        );
      }

      void arrangePocketBaseReturnsPlayingLevelRelation() {
        when(
          () => playerRecordService.getFullList(expand: 'playingLevel'),
        )..thenAnswer(
            (_) async {
              return playersFromPocketBase.map((json) {
                var expansions = <String, List<RecordModel>>{};
                if (json.containsKey('playingLevel')) {
                  expansions.putIfAbsent(
                    'playingLevel',
                    () => [RecordModel(data: playingLevelFromPocketBase)],
                  );
                }
                return RecordModel(data: json, expand: expansions);
              }).toList();
            },
          );
      }

      test(
        'pocketbase getFullList is called',
        () async {
          arrangePocketBaseReturnsPlayers();
          await sut.getList();
          verify(() => pocketBase.collection('players').getFullList())
              .called(1);
          verify(
            () => playerRecordService.getFullList(expand: any(named: 'expand')),
          ).called(1);
        },
      );

      test(
        'Parsed Player objects match json from pocketbase',
        () async {
          arrangePocketBaseReturnsPlayers();
          List<Player> players = await sut.getList();
          expect(players.length, playersFromPocketBase.length);
          for (int i = 0; i < players.length; i++) {
            expect(players[i].id, playersFromPocketBase[i]['id']);
            expect(players[i].firstName, playersFromPocketBase[i]['firstName']);
            expect(players[i].lastName, playersFromPocketBase[i]['lastName']);
            if (playersFromPocketBase[i].containsKey('gender')) {
              expect(
                players[i].gender?.name,
                playersFromPocketBase[i]['gender'],
              );
            }
            if (playersFromPocketBase[i].containsKey('dateOfBirth')) {
              expect(
                players[i].dateOfBirth?.toIso8601String(),
                playersFromPocketBase[i]['dateOfBirth'],
              );
            }
          }
        },
      );

      test(
        """ExpansionTree produces a call to RecordService with expand String,
        parsed Player objects contain expanded relation fields""",
        () async {
          arrangePocketBaseReturnsPlayingLevelRelation();
          List<Player> players = await sut.getList(
              expand: ExpansionTree(
            Player.expandedFields.where((field) => field.key == 'playingLevel'),
          ));
          verify(() => playerRecordService.getFullList(expand: 'playingLevel'))
              .called(1);
          var expandedPlayers =
              players.where((p) => p.playingLevel != null).toList();
          expect(expandedPlayers.length, 1);
          expect(
            expandedPlayers[0].playingLevel!.name,
            playingLevelFromPocketBase['name'],
          );
        },
      );
    },
  );

  group(
    'Creating data',
    () {
      final newPlayer = Player.newPlayer().copyWith(
        firstName: 'Lin',
        lastName: 'Dan',
        dateOfBirth: DateTime(1983, 10, 14),
        gender: Gender.male,
      );

      final updatedPlayer = Player.newPlayer().copyWith(
        id: 'alreadyexisting',
        updated: DateTime(2023),
        firstName: 'Gillian',
        lastName: 'Clark',
        dateOfBirth: DateTime(1961, 9, 2),
        gender: Gender.female,
      );

      void arrangePocketBaseCreatesPlayer() {
        when(() => playerRecordService.create(
              body: any(named: 'body'),
              expand: any(named: 'expand'),
            )).thenAnswer((invocation) async {
          Map<String, dynamic> json =
              Map.from(invocation.namedArguments[#body]);
          var record = RecordModel(
            id: 'freshnewid12345',
            created: '2023-05-18T12:14:24.274',
            updated: '2023-05-18T12:14:24.274',
            data: json,
          );
          return record;
        });
      }

      void arrangePocketBaseUpdatesPlayer() {
        when(() => playerRecordService.update(
              any(),
              body: any(named: 'body'),
              expand: any(named: 'expand'),
            )).thenAnswer((invocation) async {
          Map<String, dynamic> json =
              Map.from(invocation.namedArguments[#body]);
          String id = invocation.positionalArguments[0];
          var record = RecordModel(
            id: id,
            created: '2023-05-18T12:14:24.274',
            updated: '2023-05-18T15:42:27.274',
            data: json,
          );
          return record;
        });
      }

      test('pocketbase create is called', () async {
        arrangePocketBaseCreatesPlayer();
        await sut.create(newPlayer);
        verify(() => playerRecordService.create(
              body: any(named: 'body'),
              expand: any(named: 'expand'),
            )).called(1);
      });

      test('pocketbase update is called', () async {
        arrangePocketBaseUpdatesPlayer();
        await sut.update(updatedPlayer);
        verify(() => playerRecordService.update(
              any(),
              body: any(named: 'body'),
              expand: any(named: 'expand'),
            )).called(1);
      });

      test('created player has new ID and correct data', () async {
        arrangePocketBaseCreatesPlayer();
        Player player = await sut.create(newPlayer);
        expect(player.id, 'freshnewid12345');
        expect(player.firstName, newPlayer.firstName);
        expect(player.lastName, newPlayer.lastName);
        expect(player.dateOfBirth, newPlayer.dateOfBirth);
        expect(player.eMail, newPlayer.eMail);
        expect(player.gender, newPlayer.gender);
      });

      test('updated player has same ID and correct data', () async {
        arrangePocketBaseUpdatesPlayer();
        Player player = await sut.update(updatedPlayer);
        expect(player.id, updatedPlayer.id);
        expect(player.updated, isNot(updatedPlayer.updated));
        expect(player.firstName, updatedPlayer.firstName);
        expect(player.lastName, updatedPlayer.lastName);
        expect(player.dateOfBirth, updatedPlayer.dateOfBirth);
        expect(player.eMail, updatedPlayer.eMail);
        expect(player.gender, updatedPlayer.gender);
      });
    },
  );
}
