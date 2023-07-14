import 'package:collection/collection.dart';
import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/list_sorting/comparator/list_sorting_comparator.dart';
import 'package:ez_badminton_admin_app/player_management/player_sorter/comparators/creation_date_comparator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final Player firstCreatedPlayer = Player.newPlayer().copyWith(
    id: 'firstPlayer',
    created: DateTime(2022),
  );
  final Player secondCreatedPlayer = Player.newPlayer().copyWith(
    id: 'secondPlayer',
    created: DateTime(2023),
  );

  group('CreationDateComparator', () {
    test('comparisons', () {
      CreationDateComparator sut = const CreationDateComparator();
      expect(
        [firstCreatedPlayer, secondCreatedPlayer].sorted(sut.comparator),
        [secondCreatedPlayer, firstCreatedPlayer],
      );
    });

    test('copyWith', () {
      CreationDateComparator sut = const CreationDateComparator();
      expect(sut.copyWith(ComparatorMode.descending), sut);
    });
  });
}
