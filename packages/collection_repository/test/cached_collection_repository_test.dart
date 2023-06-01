import 'dart:async';

import 'package:collection_repository/collection_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockCollectionRepository<M extends Model> extends Mock
    implements CollectionRepository<M> {}

void main() {
  late CachedCollectionRepository<Player> sut;
  late MockCollectionRepository<Player> targetCollectionRepository;

  setUp(() {
    targetCollectionRepository = MockCollectionRepository<Player>();
    sut = CachedCollectionRepository(targetCollectionRepository);
  });

  group('call delegation to the wrapped targetCollectionRepository', () {
    setUp(() {
      when(
        () => targetCollectionRepository.updateStream,
      ).thenAnswer((_) => Stream.fromIterable([]));

      when(
        () => targetCollectionRepository.dispose(),
      ).thenAnswer((invocation) async {});
    });

    test(
      'decorator returns update stream of targetCollectionRepository',
      () {
        sut.updateStream;
        verify(() => targetCollectionRepository.updateStream).called(1);
      },
    );

    test(
      'decorator calls dispose() of targetCollectionRepository',
      () {
        sut.dispose();
        verify(() => targetCollectionRepository.dispose()).called(1);
      },
    );
  });

  group('cached collection queries', () {
    var playerCollection = ['0', '1', '2']
        .map((id) => Player.newPlayer().copyWith(id: id))
        .toList();
    setUp(() {
      registerFallbackValue(Player.newPlayer());

      when(
        () => targetCollectionRepository.getModel(
          any(),
          expand: any(named: 'expand'),
        ),
      ).thenAnswer((invocation) async {
        var id = int.parse(invocation.positionalArguments[0]);
        await Future.delayed(const Duration(milliseconds: 1));
        return playerCollection[id];
      });

      when(
        () => targetCollectionRepository.getList(expand: any(named: 'expand')),
      ).thenAnswer((invocation) async {
        await Future.delayed(const Duration(milliseconds: 1));
        return playerCollection;
      });

      when(
        () => targetCollectionRepository.update(
          any(),
          expand: any(named: 'expand'),
        ),
      ).thenAnswer((invocation) async {
        var player = invocation.positionalArguments[0] as Player;
        return player;
      });

      when(
        () => targetCollectionRepository.create(
          any(),
          expand: any(named: 'expand'),
        ),
      ).thenAnswer((invocation) async {
        var player = invocation.positionalArguments[0] as Player;
        return player;
      });

      when(
        () => targetCollectionRepository.delete(any()),
      ).thenAnswer((invocation) async {});
    });

    Completer<T> wrapInCompleter<T>(Future<T> future) {
      final completer = Completer<T>();
      future.then(completer.complete);
      return completer;
    }

    test(
      """first list fetch is cache miss, following is cache hit, both fetch
      results are equal""",
      () async {
        var uncachedFetch = wrapInCompleter(sut.getList());
        await Future.delayed(Duration.zero);
        expect(uncachedFetch.isCompleted, false);
        var uncachedResult = await uncachedFetch.future;

        var cachedFetch = wrapInCompleter(sut.getList());
        await Future.delayed(Duration.zero);
        expect(cachedFetch.isCompleted, true);
        var cachedResult = await cachedFetch.future;

        expect(uncachedResult, cachedResult);
      },
    );

    test(
      """first single fetch is cache miss, following is cache hit, both fetch
      results are equal""",
      () async {
        var uncachedFetch = wrapInCompleter(sut.getModel('0'));
        await Future.delayed(Duration.zero);
        expect(uncachedFetch.isCompleted, false);
        var uncachedResult = await uncachedFetch.future;

        var cachedFetch = wrapInCompleter(sut.getModel('0'));
        await Future.delayed(Duration.zero);
        expect(cachedFetch.isCompleted, true);
        var cachedResult = await cachedFetch.future;

        expect(uncachedResult, cachedResult);
      },
    );

    test(
      'creating a model also caches it',
      () async {
        await sut.create(playerCollection[0]);
        var cachedFetch = wrapInCompleter(sut.getModel('0'));
        await Future.delayed(Duration.zero);
        expect(cachedFetch.isCompleted, true);
        var cachedResult = await cachedFetch.future;

        expect(cachedResult, playerCollection[0]);
      },
    );

    test(
      'updating a model also caches it',
      () async {
        expect(await sut.getList(), playerCollection);
        await sut.update(playerCollection[0].copyWith(firstName: 'updated'));
        var cachedFetch = wrapInCompleter(sut.getList());
        await Future.delayed(Duration.zero);
        expect(cachedFetch.isCompleted, true);
        var cachedResult = await cachedFetch.future;

        expect(cachedResult.length, playerCollection.length);
        expect(
          cachedResult
              .where((p) => p.id == playerCollection[0].id)
              .first
              .firstName,
          'updated',
        );
      },
    );

    test(
      'deleting a model also deletes it from cache',
      () async {
        await sut.getList();
        await sut.delete(playerCollection[0]);
        var cachedResult = await sut.getList();

        expect(cachedResult.length, playerCollection.length - 1);
        expect(cachedResult.contains(playerCollection[0]), false);
      },
    );

    test(
      """fetching the full list after fetching some single models replaces the
      cache with the full list""",
      () async {
        await sut.getModel('0');
        await sut.getModel('1');

        when(
          () =>
              targetCollectionRepository.getList(expand: any(named: 'expand')),
        ).thenAnswer((invocation) async {
          return playerCollection
              .map((p) => p.copyWith(firstName: 'changed'))
              .toList();
        });

        var uncachedResult = await sut.getList();

        expect(uncachedResult.length, playerCollection.length);
        expect(
          uncachedResult.where((p) => p.firstName == 'changed'),
          uncachedResult,
        );
      },
    );
  });
}
