import 'package:collection_repository/collection_repository.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:pocketbase_provider/pocketbase_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:expect_stream/expect_stream.dart';

import 'update_event_matchers.dart';

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

  group('initialization and disposal', () {
    test('update stream can be listened to', () {
      expect(sut.updateStream.first, anything);
    });

    test('update stream is closed after dispose()', () async {
      await sut.dispose();
      expect(sut.updateStream.first, throwsA(anything));
    }, timeout: const Timeout(Duration(milliseconds: 500)));
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
          'status': 'notAttending',
        },
        {
          // All non-relation fields for Player
          'id': 'jsi7rtn1mo054da',
          'created': '2023-05-18T12:14:24.274',
          'updated': '2023-05-18T12:14:24.274',
          'firstName': 'Viktor',
          'lastName': 'Axelsen',
          'notes': 'player@example.com',
          'status': 'notAttending',
        },
        {
          // Some fields set as empty
          // (pocketbase sends null fields as empty strings)
          'id': '7fn2hj0m1n48s5x',
          'created': '2023-05-18T12:14:24.274',
          'updated': '2023-05-18T12:14:24.274',
          'firstName': 'He',
          'lastName': 'Bingjiao',
          'notes': '',
          'status': 'notAttending',
        },
        {
          // Player with relations
          'id': '7fn2hj0m1n48s5x',
          'created': '2023-05-18T12:14:24.274',
          'updated': '2023-05-18T12:14:24.274',
          'firstName': 'Lee',
          'lastName': 'Chong Wei',
          'club': 'relatedfield123',
          'status': 'notAttending',
        },
      ];

      final clubFromPocketBase = <String, dynamic>{
        'id': 'relatedfield123',
        'created': '2023-05-18T12:14:24.274',
        'updated': '2023-05-18T12:14:24.274',
        'name': 'very good player',
      };

      void arrangePocketBaseReturnsPlayers() {
        when(
          () => playerRecordService.getFullList(expand: any(named: 'expand')),
        ).thenAnswer(
          (_) async {
            return playersFromPocketBase
                .map((json) => RecordModel(id: json['id'], data: Map.of(json)))
                .toList();
          },
        );
      }

      void arrangePocketBaseReturnsPlayingLevelRelation() {
        when(
          () => playerRecordService.getFullList(expand: 'club'),
        ).thenAnswer(
          (_) async {
            return playersFromPocketBase.map((json) {
              var expansions = <String, List<RecordModel>>{};
              if (json.containsKey('club')) {
                expansions.putIfAbsent(
                  'club',
                  () => [
                    RecordModel(
                      id: clubFromPocketBase['id'],
                      data: Map.of(clubFromPocketBase),
                    )
                  ],
                );
              }
              return RecordModel(
                id: json['id'],
                data: Map.of(json),
                expand: expansions,
              );
            }).toList();
          },
        );
      }

      void arrangePocketBaseReturnsOnePlayer() {
        when(
          () => playerRecordService.getOne(
            any(),
            expand: any(named: 'expand'),
          ),
        ).thenAnswer((_) async {
          return RecordModel(data: Map.of(playersFromPocketBase[0]));
        });
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
        'Parsed Player collection matches json from pocketbase',
        () async {
          arrangePocketBaseReturnsPlayers();
          List<Player> players = await sut.getList();
          expect(players.length, playersFromPocketBase.length);
          for (int i = 0; i < players.length; i++) {
            expect(players[i].id, playersFromPocketBase[i]['id']);
            expect(players[i].firstName, playersFromPocketBase[i]['firstName']);
            expect(players[i].lastName, playersFromPocketBase[i]['lastName']);
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
            Player.expandedFields.where((field) => field.key == 'club'),
          ));
          verify(() => playerRecordService.getFullList(expand: 'club'))
              .called(1);
          var expandedPlayers = players.where((p) => p.club != null).toList();
          expect(expandedPlayers.length, 1);
          expect(
            expandedPlayers[0].club!.name,
            clubFromPocketBase['name'],
          );
        },
      );

      test(
        'pocketbase getOne is called',
        () async {
          arrangePocketBaseReturnsOnePlayer();
          await sut.getModel('xyz');
          verify(() => playerRecordService.getOne(
                any(),
                expand: any(named: 'expand'),
              )).called(1);
        },
      );
    },
  );

  group(
    'Modifying data',
    () {
      final newPlayer = Player.newPlayer().copyWith(
        firstName: 'Lin',
        lastName: 'Dan',
      );

      final updatedPlayer = Player.newPlayer().copyWith(
        id: 'alreadyexisting',
        updated: DateTime(2023),
        firstName: 'Gillian',
        lastName: 'Clark',
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

      void arrangePocketBaseDeletesPlayer() {
        when(
          () => playerRecordService.delete(any()),
        ).thenAnswer((_) async {});
      }

      test('pocketbase create is called', () async {
        arrangePocketBaseCreatesPlayer();
        await sut.create(newPlayer);
        verify(() => playerRecordService.create(
              body: any(named: 'body'),
              expand: any(named: 'expand'),
            )).called(1);
      });

      test('update stream emits create event', () async {
        arrangePocketBaseCreatesPlayer();
        var expectation = expectBroadcastStream(
          sut.updateStream,
          [
            allOf(
              HasType(UpdateType.create),
              HasModel(WithId('freshnewid12345')),
            ),
          ],
        );
        await sut.create(newPlayer);
        sut.dispose();
        await expectation;
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

      test('update stream emits update event', () async {
        arrangePocketBaseUpdatesPlayer();
        var expectation = expectBroadcastStream(
          sut.updateStream,
          [
            allOf(
              HasType(UpdateType.update),
              HasModel(updatedPlayer),
            ),
          ],
        );
        await sut.update(updatedPlayer);
        sut.dispose();
        await expectation;
      });

      test('created player has new ID and correct data', () async {
        arrangePocketBaseCreatesPlayer();
        Player player = await sut.create(newPlayer);
        expect(player.id, 'freshnewid12345');
        expect(player.firstName, newPlayer.firstName);
        expect(player.lastName, newPlayer.lastName);
        expect(player.notes, newPlayer.notes);
      });

      test('updated player has same ID and correct data', () async {
        arrangePocketBaseUpdatesPlayer();
        Player player = await sut.update(updatedPlayer);
        expect(player.id, updatedPlayer.id);
        expect(player.updated, isNot(updatedPlayer.updated));
        expect(player.firstName, updatedPlayer.firstName);
        expect(player.lastName, updatedPlayer.lastName);
        expect(player.notes, updatedPlayer.notes);
      });

      test('pocketbase delete is called', () async {
        arrangePocketBaseDeletesPlayer();
        await sut.delete(updatedPlayer);
        verify(() => playerRecordService.delete(any())).called(1);
      });

      test('update stream emits delete event', () async {
        arrangePocketBaseDeletesPlayer();
        var expectation = expectBroadcastStream(
          sut.updateStream,
          [
            allOf(
              HasType(UpdateType.delete),
              HasModel(updatedPlayer),
            ),
          ],
        );
        await sut.delete(updatedPlayer);
        sut.dispose();
        await expectation;
      });
    },
  );

  group('error cases', () {
    setUp(() {
      when(
        () => playerRecordService.getFullList(expand: any(named: 'expand')),
      ).thenAnswer((_) => throw ClientException(statusCode: 42));

      when(
        () => playerRecordService.getOne(any(), expand: any(named: 'expand')),
      ).thenAnswer((_) => throw ClientException(statusCode: 42));

      when(
        () => playerRecordService.create(
          body: any(named: 'body'),
          expand: any(named: 'expand'),
        ),
      ).thenAnswer((_) => throw ClientException(statusCode: 42));

      when(
        () => playerRecordService.update(
          any(),
          body: any(named: 'body'),
          expand: any(named: 'expand'),
        ),
      ).thenAnswer((_) => throw ClientException(statusCode: 42));

      when(
        () => playerRecordService.delete(any()),
      ).thenAnswer((_) => throw ClientException(statusCode: 42));
    });

    test(
      'list fetch throws CollectionQueryException when pocketbase throws',
      () async {
        try {
          await sut.getList();
        } catch (e) {
          expect(e, isA<CollectionQueryException>());
          expect((e as CollectionQueryException).errorCode, '42');
          return;
        }
        assert(false, 'No exception thrown');
      },
    );

    test(
      'single fetch throws CollectionQueryException when pocketbase throws',
      () async {
        try {
          await sut.getModel('abc');
        } catch (e) {
          expect(e, isA<CollectionQueryException>());
          expect((e as CollectionQueryException).errorCode, '42');
          return;
        }
        assert(false, 'No exception thrown');
      },
    );

    test(
      'create throws CollectionQueryException when pocketbase throws',
      () async {
        try {
          await sut.create(Player.newPlayer());
        } catch (e) {
          expect(e, isA<CollectionQueryException>());
          expect((e as CollectionQueryException).errorCode, '42');
          return;
        }
        assert(false, 'No exception thrown');
      },
    );

    test(
      'update throws CollectionQueryException when pocketbase throws',
      () async {
        try {
          await sut.update(Player.newPlayer().copyWith(id: 'id'));
        } catch (e) {
          expect(e, isA<CollectionQueryException>());
          expect((e as CollectionQueryException).errorCode, '42');
          return;
        }
        assert(false, 'No exception thrown');
      },
    );

    test(
      'delete throws CollectionQueryException when pocketbase throws',
      () async {
        try {
          await sut.delete(Player.newPlayer().copyWith(id: 'id'));
        } catch (e) {
          expect(e, isA<CollectionQueryException>());
          expect((e as CollectionQueryException).errorCode, '42');
          return;
        }
        assert(false, 'No exception thrown');
      },
    );
  });
}
