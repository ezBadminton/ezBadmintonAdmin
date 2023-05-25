import 'package:collection/collection.dart';
import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/collection_queries/collection_querier.dart';
import 'package:ez_badminton_admin_app/input_models/models.dart';
import 'package:ez_badminton_admin_app/input_models/no_validation.dart';
import 'package:ez_badminton_admin_app/player_management/player_editing/cubit/competition_registration_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CompetitionRegistrationCubit extends Cubit<CompetitionRegistrationState>
    with CollectionGetter {
  CompetitionRegistrationCubit(
    super.initialState, {
    required this.registrationIndex,
    required Map<Type, List<Model>> playerListCollections,
  }) : collections = playerListCollections;

  final int registrationIndex;
  @override
  final Map<Type, List<Model>> collections;

  void formStepForward(int registrationIndex) {
    var newState = state.copyWith(formStep: state.formStep + 1);
    emit(newState);
  }

  List<PlayingLevel> getAvailablePlayingLevels() {
    return getCollection<Competition>()
        .map((c) => c.playingLevels)
        .expand((levels) => levels)
        .toSet()
        .sorted((a, b) => a.index > b.index ? 1 : -1);
  }

  List<AgeGroup> getAvailableAgeGroups() {
    return getCollection<Competition>()
        .map((c) => c.ageGroups)
        .expand((groups) => groups)
        .toSet()
        .sorted((a, b) => a.age > b.age ? 1 : -1);
  }

  List<GenderCategory> getAvailableGenderCategories() {
    var presentGenderCategories =
        getCollection<Competition>().map((c) => c.genderCategory);
    return GenderCategory.values
        .where((t) => presentGenderCategories.contains(t))
        .toList();
  }

  List<CompetitionType> getAvailableCompetitionTypes() {
    var presentCompetitionTypes =
        getCollection<Competition>().map((c) => c.getCompetitionType());
    return CompetitionType.values
        .where((t) => presentCompetitionTypes.contains(t))
        .toList();
  }

  List<Competition> getSelectedCompetitions(int registrationIndex) {
    return getCollection<Competition>().where((competition) {
      var typeMatch =
          competition.getCompetitionType() == state.competitionType.value;
      var genderCategoryMatch =
          competition.genderCategory == GenderCategory.any ||
              competition.genderCategory == state.genderCategory.value;
      var ageGroupMatch = competition.ageGroups.isEmpty ||
          competition.ageGroups.contains(state.ageGroup.value);
      var playingLevelMatch = competition.playingLevels.isEmpty ||
          competition.playingLevels.contains(state.playingLevel.value);
      return typeMatch &&
          genderCategoryMatch &&
          ageGroupMatch &&
          playingLevelMatch;
    }).toList();
  }

  void competitionTypeChanged(
    int registrationIndex,
    CompetitionType? competitionType,
  ) {
    var newState = state.copyWith(
        competitionType: SelectionInput.dirty(value: competitionType));
    emit(newState);
  }

  void competitionPlayingLevelChanged(
    int registrationIndex,
    PlayingLevel? playingLevel,
  ) {
    var newState =
        state.copyWith(playingLevel: SelectionInput.dirty(value: playingLevel));
    emit(newState);
  }

  void genderCategoryChanged(
    int registrationIndex,
    GenderCategory? genderCategory,
  ) {
    var newState = state.copyWith(
        genderCategory: SelectionInput.dirty(value: genderCategory));
    emit(newState);
  }

  void ageGroupChanged(
    int registrationIndex,
    AgeGroup? ageGroup,
  ) {
    var newState =
        state.copyWith(ageGroup: SelectionInput.dirty(value: ageGroup));
    emit(newState);
  }

  void partnerNameChanged(int registrationIndex, String partnerName) {
    var newState =
        state.copyWith(partnerName: NoValidationInput.dirty(partnerName));
    emit(newState);
  }
}
