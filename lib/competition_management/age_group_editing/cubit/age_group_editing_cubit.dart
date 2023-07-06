import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/collection_queries/collection_querier.dart';
import 'package:ez_badminton_admin_app/input_models/models.dart';
import 'package:ez_badminton_admin_app/widgets/loading_screen/loading_screen.dart';
import 'package:formz/formz.dart';

part 'age_group_editing_state.dart';

class AgeGroupEditingCubit
    extends CollectionFetcherCubit<AgeGroupEditingState> {
  AgeGroupEditingCubit({
    required CollectionRepository<AgeGroup> ageGroupRepository,
    required CollectionRepository<Competition> competitionRepository,
  }) : super(
          collectionRepositories: [
            ageGroupRepository,
            competitionRepository,
          ],
          AgeGroupEditingState(),
        ) {
    loadAgeGroups();
  }

  void loadAgeGroups() {
    if (state.loadingStatus != LoadingStatus.loading) {
      emit(state.copyWith(loadingStatus: LoadingStatus.loading));
    }
    fetchCollectionsAndUpdateState(
      [
        collectionFetcher<AgeGroup>(),
        collectionFetcher<Competition>(),
      ],
      onSuccess: (updatedState) {
        List<AgeGroup> ageGroups = updatedState.getCollection<AgeGroup>();

        ageGroups.sort(_compareAgeGroups);
        updatedState = updatedState.copyWithCollection(
          modelType: AgeGroup,
          collection: ageGroups,
        );

        emit(updatedState.copyWith(loadingStatus: LoadingStatus.done));
      },
      onFailure: () {
        emit(state.copyWith(loadingStatus: LoadingStatus.failed));
      },
    );
  }

  void ageGroupTypeChanged(AgeGroupType? type) {
    emit(
      state.copyWith(
        ageGroupType: SelectionInput.dirty(
          emptyAllowed: true,
          value: type,
        ),
      ),
    );
  }

  void ageChanged(String age) {
    assert(age.isEmpty || int.tryParse(age) != null);
    emit(state.copyWith(age: NoValidationInput.dirty(age)));
  }

  void ageGroupSubmitted() {
    if (!state.isSubmittable) {
      return;
    }

    AgeGroup newAgeGroup = AgeGroup.newAgeGroup(
      type: state.ageGroupType.value!,
      age: int.parse(state.age.value),
    );

    _addAgeGroup(newAgeGroup);
  }

  void _addAgeGroup(AgeGroup newAgeGroup) async {
    if (state.formStatus == FormzSubmissionStatus.inProgress) {
      return;
    }
    emit(state.copyWith(formStatus: FormzSubmissionStatus.inProgress));

    AgeGroup? newAgeGroupFromDB = await querier.createModel(newAgeGroup);
    if (isClosed) {
      return;
    }
    if (newAgeGroupFromDB == null) {
      emit(state.copyWith(formStatus: FormzSubmissionStatus.failure));
      return;
    }
    emit(state.copyWith(formStatus: FormzSubmissionStatus.success));
    loadAgeGroups();
  }

  void ageGroupRemoved(AgeGroup removedAgeGroup) async {
    assert(
      removedAgeGroup.id.isNotEmpty,
      'Given AgeGroup does not exist on DB',
    );
    if (state.formStatus == FormzSubmissionStatus.inProgress) {
      return;
    }
    emit(state.copyWith(formStatus: FormzSubmissionStatus.inProgress));

    Iterable<Competition> competitionsUsingAgeGroup = state
        .getCollection<Competition>()
        .where((c) => c.ageGroups.contains(removedAgeGroup));
    if (competitionsUsingAgeGroup.isNotEmpty) {
      // Don't delete age groups that are used
      emit(state.copyWith(formStatus: FormzSubmissionStatus.failure));
      return;
    }

    bool ageGroupDeleted = await querier.deleteModel(removedAgeGroup);
    if (isClosed) {
      return;
    }
    if (!ageGroupDeleted) {
      emit(state.copyWith(formStatus: FormzSubmissionStatus.failure));
      return;
    }
    emit(state.copyWith(formStatus: FormzSubmissionStatus.success));
    loadAgeGroups();
  }

  static int _compareAgeGroups(AgeGroup ageGroup1, AgeGroup ageGroup2) {
    int typeIndex1 = AgeGroupType.values.indexOf(ageGroup1.type);
    int typeIndex2 = AgeGroupType.values.indexOf(ageGroup2.type);
    // Sort by age group type over < under
    int typeComparison = typeIndex1.compareTo(typeIndex2);

    if (typeComparison != 0) {
      return typeComparison;
    }

    // Sort by age descending
    int ageComparison = ageGroup2.age.compareTo(ageGroup1.age);
    return ageComparison;
  }
}
