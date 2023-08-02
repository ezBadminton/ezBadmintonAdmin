import 'package:bloc_test/bloc_test.dart';
import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/competition_management/age_group_editing/cubit/age_group_editing_cubit.dart';
import 'package:ez_badminton_admin_app/widgets/loading_screen/loading_screen.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:formz/formz.dart';

import '../../common_matchers/model_matchers.dart';
import '../../common_matchers/state_matchers.dart';
import '../../test_collection_repository/test_collection_repository.dart';

class HasSelectedAgeGroupType extends CustomMatcher {
  HasSelectedAgeGroupType(matcher)
      : super(
          'State with',
          'AgeGroupType',
          matcher,
        );
  @override
  featureValueOf(actual) => actual.ageGroupType.value;
}

class HasAgeGroupAge extends CustomMatcher {
  HasAgeGroupAge(matcher)
      : super(
          'State with',
          'AgeGroup age',
          matcher,
        );
  @override
  featureValueOf(actual) => actual.age.value;
}

List<AgeGroup> ageGroups = List.generate(
  2,
  (index) => AgeGroup.newAgeGroup(age: index + 10, type: AgeGroupType.over)
      .copyWith(id: 'AgeGroup-$index'),
);

void main() {
  late CollectionRepository<AgeGroup> ageGroupRepository;
  late CollectionRepository<Competition> competitionRepository;
  late CollectionRepository<Team> teamRepository;

  void arrangeRepositories({
    bool throwing = false,
    List<AgeGroup> ageGroups = const [],
    List<Competition> competitions = const [],
    List<Team> teams = const [],
  }) {
    ageGroupRepository = TestCollectionRepository(
      initialCollection: ageGroups,
      throwing: throwing,
    );
    competitionRepository = TestCollectionRepository(
      initialCollection: competitions,
      throwing: throwing,
    );
    teamRepository = TestCollectionRepository(
      initialCollection: teams,
      throwing: throwing,
    );
  }

  AgeGroupEditingCubit createSut() {
    return AgeGroupEditingCubit(
      ageGroupRepository: ageGroupRepository,
      competitionRepository: competitionRepository,
      teamRepository: teamRepository,
    );
  }

  setUp(() {
    arrangeRepositories();
  });

  group('AgeGroupEditingCubit', () {
    test('initial state', () {
      AgeGroupEditingCubit sut = createSut();
      expect(sut.state, HasLoadingStatus(LoadingStatus.loading));
      expect(sut.state, HasFormStatus(FormzSubmissionStatus.initial));
      expect(sut.state.formSubmittable, isFalse);
      expect(sut.state.isDeletable, isFalse);
    });

    blocTest<AgeGroupEditingCubit, AgeGroupEditingState>(
      'create age groups',
      build: createSut,
      act: (cubit) async {
        await Future.delayed(Duration.zero);
        cubit.ageGroupTypeChanged(AgeGroupType.over);
        cubit.ageChanged('15');
        cubit.ageGroupSubmitted();
        await Future.delayed(Duration.zero);
        cubit.ageGroupTypeChanged(AgeGroupType.under);
        cubit.ageChanged('25');
        cubit.ageGroupSubmitted();
      },
      skip: 1,
      expect: () => [
        HasSelectedAgeGroupType(AgeGroupType.over),
        HasAgeGroupAge('15'),
        HasFormStatus(FormzSubmissionStatus.inProgress),
        HasFormStatus(FormzSubmissionStatus.success),
        HasLoadingStatus(LoadingStatus.loading),
        HasLoadingStatus(LoadingStatus.done),
        HasSelectedAgeGroupType(AgeGroupType.under),
        HasAgeGroupAge('25'),
        HasFormStatus(FormzSubmissionStatus.inProgress),
        HasFormStatus(FormzSubmissionStatus.success),
        HasLoadingStatus(LoadingStatus.loading),
        HasLoadingStatus(LoadingStatus.done),
      ],
      verify: (_) async {
        List<AgeGroup> collection = await ageGroupRepository.getList();
        expect(
          collection,
          containsAll([
            allOf(
              HasAgeGroupType(AgeGroupType.over),
              HasAge(15),
            ),
            allOf(
              HasAgeGroupType(AgeGroupType.under),
              HasAge(25),
            ),
          ]),
        );
      },
    );
  });

  blocTest<AgeGroupEditingCubit, AgeGroupEditingState>(
    'try to create duplicate AgeGroup',
    setUp: () => arrangeRepositories(ageGroups: ageGroups),
    build: createSut,
    act: (cubit) async {
      await Future.delayed(Duration.zero);
      cubit.ageGroupTypeChanged(AgeGroupType.over);
      cubit.ageChanged('10');
      cubit.ageGroupSubmitted();
    },
    skip: 1,
    expect: () => [
      IsFormSubmittable(isFalse),
      IsFormSubmittable(isFalse),
    ],
  );

  blocTest<AgeGroupEditingCubit, AgeGroupEditingState>(
    'delete AgeGroup',
    setUp: () => arrangeRepositories(ageGroups: ageGroups),
    build: createSut,
    act: (cubit) async {
      await Future.delayed(Duration.zero);
      cubit.ageGroupRemoved(ageGroups[0]);
    },
    skip: 1,
    expect: () => [
      HasFormStatus(FormzSubmissionStatus.inProgress),
      HasFormStatus(FormzSubmissionStatus.success),
      HasLoadingStatus(LoadingStatus.loading),
      HasLoadingStatus(LoadingStatus.done),
    ],
    verify: (cubit) async {
      List<AgeGroup> collection = await ageGroupRepository.getList();
      expect(collection, hasLength(1));
      expect(collection, isNot(contains(ageGroups[0])));
    },
  );
}
