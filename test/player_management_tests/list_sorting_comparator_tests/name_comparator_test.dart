import 'package:collection/collection.dart';
import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/list_sorting/comparator/list_sorting_comparator.dart';
import 'package:ez_badminton_admin_app/player_management/player_sorter/comparators/name_comparator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final Player aPlayer = Player.newPlayer().copyWith(
    id: 'a-player',
    firstName: 'a',
    lastName: 'a',
  );
  final Player bPlayer = Player.newPlayer().copyWith(
    id: 'a-player',
    firstName: 'b',
    lastName: 'b',
  );
  final Player bcPlayer = Player.newPlayer().copyWith(
    id: 'a-player',
    firstName: 'c',
    lastName: 'b',
  );

  group('NameComparator', () {
    test('comparisons', () {
      NameComparator sut = NameComparator();
      expect(
        [bPlayer, bcPlayer, aPlayer]
            .sorted(sut.copyWith(ComparatorMode.ascending).comparator),
        [aPlayer, bPlayer, bcPlayer],
      );
      expect(
        [bcPlayer, aPlayer, bPlayer]
            .sorted(sut.copyWith(ComparatorMode.descending).comparator),
        [bcPlayer, bPlayer, aPlayer],
      );
    });
  });
}
