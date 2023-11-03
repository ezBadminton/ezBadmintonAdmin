import 'package:collection/collection.dart';
import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/collection_queries/collection_querier.dart';
import 'package:ez_badminton_admin_app/competition_management/utils/competition_queries.dart';
import 'package:ez_badminton_admin_app/utils/sorting.dart';
import 'package:ez_badminton_admin_app/input_models/models.dart';
import 'package:ez_badminton_admin_app/widgets/dialog_listener/cubit_mixin/dialog_cubit.dart';
import 'package:ez_badminton_admin_app/widgets/loading_screen/loading_screen.dart';
import 'package:formz/formz.dart';

part 'age_group_editing_state.dart';

class AgeGroupEditingCubit extends CollectionFetcherCubit<AgeGroupEditingState>
    with
        DialogCubit<AgeGroupEditingState>,
        CompetitionDeletionQueries,
        RemovedCategoryCompetitionManagement<AgeGroupEditingState> {
  AgeGroupEditingCubit({
    required CollectionRepository<AgeGroup> ageGroupRepository,
    required CollectionRepository<Competition> competitionRepository,
    required CollectionRepository<Team> teamRepository,
  }) : super(
          collectionRepositories: [
            ageGroupRepository,
            competitionRepository,
            teamRepository,
          ],
          AgeGroupEditingState(),
        ) {
    loadCollections();
    subscribeToCollectionUpdates(
      competitionRepository,
      (_) => loadCollections(),
    );
    subscribeToCollectionUpdates(
      teamRepository,
      (_) => loadCollections(),
    );
  }

  void loadCollections() {
    if (state.loadingStatus != LoadingStatus.loading) {
      emit(state.copyWith(loadingStatus: LoadingStatus.loading));
    }
    fetchCollectionsAndUpdateState(
      [
        collectionFetcher<AgeGroup>(),
        collectionFetcher<Competition>(),
        collectionFetcher<Team>(),
      ],
      onSuccess: (updatedState) {
        updatedState = updatedState.copyWithAgeGroupSorting();

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
    if (!state.formSubmittable) {
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
    loadCollections();
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

    FormzSubmissionStatus competitionsManaged =
        await manageCompetitionsOfRemovedCategory(removedAgeGroup);
    if (competitionsManaged != FormzSubmissionStatus.success) {
      emit(state.copyWith(formStatus: competitionsManaged));
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
    loadCollections();
  }
}
