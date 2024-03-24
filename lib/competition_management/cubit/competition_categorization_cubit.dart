import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/collection_queries/collection_querier.dart';
import 'package:ez_badminton_admin_app/competition_management/cubit/competition_categorization_state.dart';
import 'package:ez_badminton_admin_app/competition_management/utils/competition_categorization.dart';
import 'package:ez_badminton_admin_app/competition_management/utils/competition_queries.dart';
import 'package:ez_badminton_admin_app/widgets/dialog_listener/cubit_mixin/dialog_cubit.dart';
import 'package:ez_badminton_admin_app/widgets/loading_screen/loading_screen.dart';
import 'package:formz/formz.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CompetitionCategorizationCubit
    extends CollectionQuerierCubit<CompetitionCategorizationState>
    with
        DialogCubit,
        RemovedCategoryCompetitionManagement<CompetitionCategorizationState> {
  CompetitionCategorizationCubit({
    required this.l10n,
    required CollectionRepository<Tournament> tournamentRepository,
    required CollectionRepository<Competition> competitionRepository,
    required CollectionRepository<AgeGroup> ageGroupRepository,
    required CollectionRepository<PlayingLevel> playingLevelRepository,
  }) : super(
          collectionRepositories: [
            tournamentRepository,
            competitionRepository,
            ageGroupRepository,
            playingLevelRepository,
          ],
          CompetitionCategorizationState(),
        );

  final AppLocalizations l10n;

  @override
  void onCollectionUpdate(
    List<List<Model>> collections,
    List<CollectionUpdateEvent<Model>> updateEvents,
  ) {
    CompetitionCategorizationState updatedState = state.copyWith(
      collections: collections,
      loadingStatus: LoadingStatus.done,
    );

    emit(updatedState);
  }

  void useAgeGroupsChanged(bool useAgeGroups) {
    Tournament updatedTournament = state.tournament.copyWith(
      useAgeGroups: useAgeGroups,
    );
    _updateCategorization<AgeGroup>(updatedTournament);
  }

  void usePlayingLevelsChanged(bool usePlayingLevels) {
    Tournament updatedTournament = state.tournament.copyWith(
      usePlayingLevels: usePlayingLevels,
    );
    _updateCategorization<PlayingLevel>(updatedTournament);
  }

  void _updateCategorization<C extends Model>(
    Tournament updatedTournament,
  ) async {
    assert(C == AgeGroup || C == PlayingLevel);
    if (state.formStatus == FormzSubmissionStatus.inProgress) {
      return;
    }
    emit(state.copyWith(formStatus: FormzSubmissionStatus.inProgress));

    bool useCategorization = switch (C) {
      AgeGroup => updatedTournament.useAgeGroups,
      _ => updatedTournament.usePlayingLevels,
    };

    bool mergeConfirmed = await _confirmRegistrationMerge<C>(useCategorization);
    if (!mergeConfirmed) {
      emit(state.copyWith(formStatus: FormzSubmissionStatus.canceled));
      return;
    }

    bool categoryExists = _checkCategoryExists<C>(useCategorization);
    if (!categoryExists) {
      emit(state.copyWith(formStatus: FormzSubmissionStatus.canceled));
      return;
    }

    Tournament? updatedTournamentFromDB =
        await querier.updateModel(updatedTournament);
    if (updatedTournamentFromDB == null) {
      emit(state.copyWith(formStatus: FormzSubmissionStatus.failure));
      return;
    }

    emit(state.copyWith(
      formStatus: FormzSubmissionStatus.success,
    ));
  }

  Future<bool> _confirmRegistrationMerge<C extends Model>(
    bool useCategorization,
  ) async {
    assert(C == AgeGroup || C == PlayingLevel);

    if (useCategorization) {
      return true;
    }

    List<List<Competition>> categorizedCompetitions =
        mapByCategory<C>(state.getCollection<Competition>()).values.toList();

    List<int> registrationCounts = categorizedCompetitions
        .map((competitions) => competitions.fold(
              0,
              (previousValue, element) =>
                  previousValue + element.registrations.length,
            ))
        .toList();

    // If more than one category contains registrations, the user is warned
    // of the subsequent merging of registrations by merging of the category.
    bool doRegistrationsMerge = registrationCounts
            .where((registrationCount) => registrationCount > 0)
            .length >
        1;

    if (!doRegistrationsMerge) {
      return true;
    }

    bool mergingConfirmed = (await requestDialogChoice<bool>(reason: C))!;

    return mergingConfirmed;
  }

  bool _checkCategoryExists<C extends Model>(bool useCategorization) {
    assert(C == AgeGroup || C == PlayingLevel);

    if (!useCategorization || state.getCollection<Competition>().isEmpty) {
      return true;
    }

    bool categoryExists = state.getCollection<C>().isNotEmpty;

    if (!categoryExists) {
      requestDialogChoice<Exception>(reason: C);
    }

    return categoryExists;
  }
}
