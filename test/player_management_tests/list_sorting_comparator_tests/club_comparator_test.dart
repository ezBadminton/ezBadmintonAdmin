import 'package:collection/collection.dart';
import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/list_sorting/comparator/list_sorting_comparator.dart';
import 'package:ez_badminton_admin_app/player_management/player_sorter/comparators/club_comparator.dart';
import 'package:ez_badminton_admin_app/player_management/player_sorter/comparators/creation_date_comparator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final aClub = Club.newClub(name: 'a').copyWith(id: 'a-club');
  final bClub = Club.newClub(name: 'b').copyWith(id: 'b-club');

  final firstAClubPlayer = Player.newPlayer().copyWith(
    id: 'first-a-player',
    created: DateTime(2022),
    club: aClub,
  );
  final secondAClubPlayer = Player.newPlayer().copyWith(
    id: 'second-a-player',
    created: DateTime(2023),
    club: aClub,
  );
  final bClubPlayer = Player.newPlayer().copyWith(
    id: 'b-player',
    club: bClub,
  );
  final noClubPlayer = Player.newPlayer().copyWith(
    id: 'no-club-player',
  );

  group('ClubComparator', () {
    test('comparisons', () {
      ClubComparator sut = ClubComparator(
        secondaryComparator: const CreationDateComparator().comparator,
      );
      expect(
        [secondAClubPlayer, noClubPlayer, bClubPlayer, firstAClubPlayer]
            .sorted(sut.copyWith(ComparatorMode.ascending).comparator),
        [secondAClubPlayer, firstAClubPlayer, bClubPlayer, noClubPlayer],
      );
      expect(
        [secondAClubPlayer, noClubPlayer, bClubPlayer, firstAClubPlayer]
            .sorted(sut.copyWith(ComparatorMode.descending).comparator),
        [noClubPlayer, bClubPlayer, secondAClubPlayer, firstAClubPlayer],
      );
    });
  });
}
