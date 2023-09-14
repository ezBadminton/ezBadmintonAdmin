import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/collection_queries/collection_querier.dart';
import 'package:ez_badminton_admin_app/input_models/models.dart';
import 'package:formz/formz.dart';

part 'tournament_mode_assignment_state.dart';

class TournamentModeAssignmentCubit
    extends CollectionQuerierCubit<TournamentModeAssignmentState> {
  TournamentModeAssignmentCubit({
    required this.competitions,
    required CollectionRepository<TournamentModeSettings>
        tournamentModeSettingsRepository,
    required CollectionRepository<Competition> competitionRepository,
  }) : super(
          collectionRepositories: [
            tournamentModeSettingsRepository,
            competitionRepository,
          ],
          TournamentModeAssignmentState(),
        ) {
    if (competitions.length == 1) {
      _initializeFromExistingSettings(competitions.first);
    }
  }

  final List<Competition> competitions;

  void tournamentModeChanged(
    Type? tournamentMode, {
    TournamentModeSettings? initialSettings,
  }) {
    initialSettings = initialSettings ?? _createDefaultSettings(tournamentMode);
    TournamentModeAssignmentState newState = state.copyWith(
      modeType: SelectionInput.dirty(value: tournamentMode),
      modeSettings: SelectionInput.dirty(
        value: initialSettings,
      ),
    );

    emit(newState);
  }

  void tournamentModeSettingsChanged(TournamentModeSettings settings) {
    TournamentModeAssignmentState newState = state.copyWith(
      modeSettings: SelectionInput.dirty(
        value: settings,
      ),
    );

    emit(newState);
  }

  void formSubmitted() async {
    if (state.formStatus == FormzSubmissionStatus.inProgress ||
        state.modeSettings.value == null) {
      return;
    }
    emit(state.copyWith(formStatus: FormzSubmissionStatus.inProgress));

    TournamentModeSettings? createdSettings =
        await querier.createModel(state.modeSettings.value!);
    if (createdSettings == null) {
      emit(state.copyWith(formStatus: FormzSubmissionStatus.failure));
      return;
    }

    List<Competition> competitionsWithSettings = competitions
        .map((c) => c.copyWith(tournamentModeSettings: createdSettings))
        .toList();

    List<Competition?> updatedCompetitions =
        await querier.updateModels(competitionsWithSettings);

    if (updatedCompetitions.contains(null)) {
      emit(state.copyWith(formStatus: FormzSubmissionStatus.failure));
      return;
    }

    emit(state.copyWith(formStatus: FormzSubmissionStatus.success));
  }

  void _initializeFromExistingSettings(Competition competititon) {
    TournamentModeSettings? initialSettings =
        competitions.first.tournamentModeSettings?.copyWith(id: '');

    if (initialSettings != null) {
      tournamentModeChanged(
        _typeOfTournamentModeSettings(initialSettings),
        initialSettings: initialSettings,
      );
    }
  }

  static Type _typeOfTournamentModeSettings(
      TournamentModeSettings modeSettings) {
    switch (modeSettings) {
      case RoundRobinSettings _:
        return RoundRobinSettings;
      case SingleEliminationSettings _:
        return SingleEliminationSettings;
      case GroupKnockoutSettings _:
        return GroupKnockoutSettings;
    }
  }

  static TournamentModeSettings? _createDefaultSettings(
    Type? tournamentMode,
  ) {
    switch (tournamentMode) {
      case RoundRobinSettings:
        return RoundRobinSettings(
          id: '',
          created: DateTime.now(),
          updated: DateTime.now(),
          seedingMode: SeedingMode.random,
          passes: 1,
        );
      case SingleEliminationSettings:
        return SingleEliminationSettings(
          id: '',
          created: DateTime.now(),
          updated: DateTime.now(),
          seedingMode: SeedingMode.tiered,
        );
      case GroupKnockoutSettings:
        return GroupKnockoutSettings(
          id: '',
          created: DateTime.now(),
          updated: DateTime.now(),
          seedingMode: SeedingMode.tiered,
          numGroups: 4,
          qualificationsPerGroup: 2,
        );
      default:
        return null;
    }
  }
}
