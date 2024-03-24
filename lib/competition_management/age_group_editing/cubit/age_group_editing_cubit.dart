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

class AgeGroupEditingCubit extends CollectionQuerierCubit<AgeGroupEditingState>
    with
        DialogCubit<AgeGroupEditingState>,
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
        );

  @override
  void onCollectionUpdate(
    List<List<Model>> collections,
    List<CollectionUpdateEvent<Model>> updateEvents,
  ) {
    AgeGroupEditingState updatedState = state.copyWith(
      collections: collections,
      loadingStatus: LoadingStatus.done,
    );

    List<AgeGroup> sortedAgeGroups =
        updatedState.getCollection<AgeGroup>().sorted(compareAgeGroups);
    updatedState.overrideCollection(sortedAgeGroups);

    _emit(updatedState);
  }

  void ageGroupTypeChanged(AgeGroupType? type) {
    _emit(
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
    _emit(state.copyWith(age: NoValidationInput.dirty(age)));
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
    _emit(state.copyWith(formStatus: FormzSubmissionStatus.inProgress));

    AgeGroup? newAgeGroupFromDB = await querier.createModel(newAgeGroup);
    if (isClosed) {
      return;
    }
    if (newAgeGroupFromDB == null) {
      _emit(state.copyWith(formStatus: FormzSubmissionStatus.failure));
      return;
    }
    _emit(state.copyWith(formStatus: FormzSubmissionStatus.success));
  }

  void ageGroupRemoved(AgeGroup removedAgeGroup) async {
    assert(
      removedAgeGroup.id.isNotEmpty,
      'Given AgeGroup does not exist on DB',
    );
    if (state.formStatus == FormzSubmissionStatus.inProgress) {
      return;
    }
    _emit(state.copyWith(formStatus: FormzSubmissionStatus.inProgress));

    (FormzSubmissionStatus, Model?) replacementConfirmation =
        await askForReplacementCategory(removedAgeGroup);
    FormzSubmissionStatus confirmation = replacementConfirmation.$1;
    Model? replacementCateogry = replacementConfirmation.$2;

    if (confirmation != FormzSubmissionStatus.success) {
      _emit(state.copyWith(formStatus: confirmation));
      return;
    }

    Map<String, dynamic> query = {};
    if (replacementCateogry != null) {
      query["replacement"] = replacementCateogry.id;
    }

    bool ageGroupDeleted = await querier.deleteModel(
      removedAgeGroup,
      query: query,
    );
    if (isClosed) {
      return;
    }
    if (!ageGroupDeleted) {
      _emit(state.copyWith(formStatus: FormzSubmissionStatus.failure));
      return;
    }
    _emit(state.copyWith(formStatus: FormzSubmissionStatus.success));
  }

  void _emit(AgeGroupEditingState state) {
    bool isSubmittable = _isSubmittable(state);
    bool isDeletable = _isDeletable(state);

    emit(state.copyWith(
      formSubmittable: isSubmittable,
      isDeletable: isDeletable,
    ));
  }

  static bool _isSubmittable(AgeGroupEditingState state) {
    if (state.loadingStatus != LoadingStatus.done ||
        state.formStatus == FormzSubmissionStatus.inProgress ||
        state.ageGroupType.value == null ||
        state.age.value.isEmpty) {
      return false;
    }

    int parsedAge = int.parse(state.age.value);
    AgeGroup? existingAgeGroup = state
        .getCollection<AgeGroup>()
        .where((g) => g.type == state.ageGroupType.value && g.age == parsedAge)
        .firstOrNull;

    return existingAgeGroup == null;
  }

  static bool _isDeletable(AgeGroupEditingState state) {
    return state.loadingStatus == LoadingStatus.done &&
        state.formStatus != FormzSubmissionStatus.inProgress;
  }
}
