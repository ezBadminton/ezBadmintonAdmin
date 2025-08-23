import 'package:collection/collection.dart';
import 'package:model_repository/model_repository.dart';
import 'package:ez_badminton_admin_app/collection_queries/collection_querier.dart';
import 'package:ez_badminton_admin_app/competition_management/tournament_mode_assignment/input_models/tournament_mode_settings_input.dart';
import 'package:ez_badminton_admin_app/input_models/models.dart';
import 'package:ez_badminton_admin_app/utils/list_extension/list_extension.dart';
import 'package:ez_badminton_admin_app/widgets/dialog_listener/cubit_mixin/dialog_cubit.dart';
import 'package:formz/formz.dart';

part 'tournament_mode_assignment_state.dart';

class TournamentModeAssignmentCubit
    extends CollectionQuerierCubit<TournamentModeAssignmentState>
    with DialogCubit {
  TournamentModeAssignmentCubit({
    required List<Competition> competitions,
    required ModelStore<TournamentModeSettings>
        tournamentModeSettingsRepository,
    required ModelStore<Competition> competitionRepository,
  }) : super(
          modelStores: [
            tournamentModeSettingsRepository,
            competitionRepository,
          ],
          TournamentModeAssignmentState(competitions: competitions),
        ) {
    subscribeToCollectionUpdates(
      competitionRepository,
      _onCompetitionCollectionUpdate,
    );

    if (competitions.length == 1) {
      _initializeFromExistingSettings(competitions.first);
    }
  }

  void tournamentModeChanged(
    Type? tournamentMode, {
    TournamentModeSettings? initialSettings,
  }) {
    initialSettings = initialSettings ??
        _createDefaultSettings(
          tournamentMode,
          state.modeSettings.value,
        );
    TournamentModeAssignmentState newState = state.copyWith(
      modeType: SelectionInput.dirty(value: tournamentMode),
      modeSettings: TournamentModeSettingsInput.dirty(initialSettings),
    );

    emit(newState);
  }

  void tournamentModeSettingsChanged(TournamentModeSettings settings) {
    TournamentModeAssignmentState newState = state.copyWith(
      modeSettings: TournamentModeSettingsInput.dirty(settings),
    );

    emit(newState);
  }

  void formSubmitted() async {
    if (state.formStatus == FormzSubmissionStatus.inProgress ||
        state.modeSettings.value == null) {
      return;
    }
    emit(state.copyWith(formStatus: FormzSubmissionStatus.inProgress));

    if (state.isNotValid) {
      emit(state.copyWith(formStatus: FormzSubmissionStatus.failure));
      return;
    }

    bool willDrawsBeOverridden =
        state.competitions.firstWhereOrNull((c) => c.draw.isNotEmpty) != null;

    if (willDrawsBeOverridden) {
      bool userConfirmation = (await requestDialogChoice<bool>())!;
      if (!userConfirmation) {
        emit(state.copyWith(formStatus: FormzSubmissionStatus.canceled));
        return;
      }
    }

    var status = await _saveModeSettings();

    emit(state.copyWith(formStatus: status));
  }

  Future<FormzSubmissionStatus> _saveModeSettings() async {
    var competitionIds = state.competitions.map((c) => c.id).toList();
    TournamentModeSettings? createdSettings = await querier.createModel(
      state.modeSettings.value!,
      body: {"competitions": competitionIds},
    );
    if (createdSettings == null) {
      return FormzSubmissionStatus.failure;
    }

    return FormzSubmissionStatus.success;
  }

  void _initializeFromExistingSettings(Competition competititon) {
    TournamentModeSettings? initialSettings =
        competititon.tournamentModeSettings?.copyWith(id: '');

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
      case DoubleEliminationSettings _:
        return DoubleEliminationSettings;
      case SingleEliminationWithConsolationSettings _:
        return SingleEliminationWithConsolationSettings;
    }
  }

  static TournamentModeSettings? _createDefaultSettings(
    Type? tournamentMode,
    TournamentModeSettings? previousSettings,
  ) {
    int winningPoints = previousSettings?.winningPoints ?? 21;
    int winningSets = previousSettings?.winningSets ?? 2;
    int maxPoints = previousSettings?.maxPoints ?? 30;
    bool twoPointMargin = previousSettings?.twoPointMargin ?? true;

    switch (tournamentMode) {
      case const (RoundRobinSettings):
        return RoundRobinSettings(
          id: '',
          created: DateTime.now().toUtc(),
          updated: DateTime.now().toUtc(),
          seedingMode: SeedingMode.random,
          passes: 1,
          winningPoints: winningPoints,
          winningSets: winningSets,
          maxPoints: maxPoints,
          twoPointMargin: twoPointMargin,
        );
      case const (SingleEliminationSettings):
        return SingleEliminationSettings(
          id: '',
          created: DateTime.now().toUtc(),
          updated: DateTime.now().toUtc(),
          seedingMode: SeedingMode.tiered,
          winningPoints: winningPoints,
          winningSets: winningSets,
          maxPoints: maxPoints,
          twoPointMargin: twoPointMargin,
        );
      case const (GroupKnockoutSettings):
        return GroupKnockoutSettings(
          id: '',
          created: DateTime.now().toUtc(),
          updated: DateTime.now().toUtc(),
          seedingMode: SeedingMode.tiered,
          knockOutMode: KnockOutMode.single,
          numConsolationRounds: 0,
          placesToPlayOut: 3,
          numGroups: 4,
          numQualifications: 8,
          winningPoints: winningPoints,
          winningSets: winningSets,
          maxPoints: maxPoints,
          twoPointMargin: twoPointMargin,
        );
      case const (DoubleEliminationSettings):
        return DoubleEliminationSettings(
          id: '',
          created: DateTime.now().toUtc(),
          updated: DateTime.now().toUtc(),
          seedingMode: SeedingMode.tiered,
          winningPoints: winningPoints,
          winningSets: winningSets,
          maxPoints: maxPoints,
          twoPointMargin: twoPointMargin,
        );
      case const (SingleEliminationWithConsolationSettings):
        return SingleEliminationWithConsolationSettings(
          id: '',
          created: DateTime.now().toUtc(),
          updated: DateTime.now().toUtc(),
          seedingMode: SeedingMode.tiered,
          numConsolationRounds: 0,
          placesToPlayOut: 3,
          winningPoints: winningPoints,
          winningSets: winningSets,
          maxPoints: maxPoints,
          twoPointMargin: twoPointMargin,
        );
      default:
        throw Exception('No default settings for this mode!');
    }
  }

  void _onCompetitionCollectionUpdate(
    List<CollectionUpdateEvent<Competition>> events,
  ) {
    List<Competition> newCompetitions = List.of(state.competitions);

    for (final event in events) {
      switch (event.updateType) {
        case UpdateType.update:
          newCompetitions.replaceModel(event.model.id, event.model);
        case UpdateType.delete:
          newCompetitions.replaceModel(event.model.id, null);
        case UpdateType.create:
          break;
      }
    }

    emit(state.copyWith(competitions: newCompetitions));
  }

  @override
  void onCollectionUpdate(List<List<Model>> collections,
      List<CollectionUpdateEvent<Model>>? updateEvents) {}
}
