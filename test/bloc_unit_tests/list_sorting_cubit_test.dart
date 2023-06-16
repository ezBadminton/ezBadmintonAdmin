import 'package:bloc_test/bloc_test.dart';
import 'package:ez_badminton_admin_app/list_sorting/comparator/list_sorting_comparator.dart';
import 'package:ez_badminton_admin_app/list_sorting/cubit/list_sorting_cubit.dart';
import 'package:ez_badminton_admin_app/player_management/player_sorter/comparators/club_comparator.dart';
import 'package:ez_badminton_admin_app/player_management/player_sorter/comparators/creation_date_comparator.dart';
import 'package:ez_badminton_admin_app/player_management/player_sorter/comparators/name_comparator.dart';
import 'package:flutter_test/flutter_test.dart';

class IsInMode extends CustomMatcher {
  IsInMode(matcher)
      : super(
          'Mode of a ListSortingComparator',
          'ComparatorMode',
          matcher,
        );
  @override
  featureValueOf(actual) => (actual as ListSortingComparator).mode;
}

void main() {
  const CreationDateComparator defaultComparator = CreationDateComparator();
  final NameComparator nameComparator = NameComparator();
  final ClubComparator clubComparator = ClubComparator(
    secondaryComparator: defaultComparator.comparator!,
  );

  ListSortingCubit createSut() {
    return ListSortingCubit(
      defaultComparator: defaultComparator,
      comparators: [nameComparator, clubComparator],
    );
  }

  group('ListSortingCubit', () {
    test('inital state', () {
      ListSortingCubit sut = createSut();
      expect(sut.state, defaultComparator);
      expect(sut.getComparator<NameComparator>(), nameComparator);
      expect(sut.getComparator<ClubComparator>(), clubComparator);
      expect(
        () => sut.getComparator<CreationDateComparator>(),
        throwsAssertionError,
      );
    });

    blocTest<ListSortingCubit, ListSortingComparator>(
      'comparator toggling',
      build: createSut,
      act: (cubit) {
        cubit.comparatorToggled<NameComparator>();
        cubit.comparatorToggled<NameComparator>();
        cubit.comparatorToggled<NameComparator>();

        cubit.comparatorToggled<NameComparator>();
        cubit.comparatorToggled<ClubComparator>();
        cubit.comparatorToggled<ClubComparator>();
        cubit.comparatorToggled<ClubComparator>();
      },
      expect: () => [
        allOf(
          isA<NameComparator>(),
          IsInMode(ComparatorMode.ascending),
        ),
        allOf(
          isA<NameComparator>(),
          IsInMode(ComparatorMode.descending),
        ),
        defaultComparator,
        allOf(
          isA<NameComparator>(),
          IsInMode(ComparatorMode.ascending),
        ),
        allOf(
          isA<ClubComparator>(),
          IsInMode(ComparatorMode.ascending),
        ),
        allOf(
          isA<ClubComparator>(),
          IsInMode(ComparatorMode.descending),
        ),
        defaultComparator,
      ],
    );
  });
}
