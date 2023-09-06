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
  }) : super(
          collectionRepositories: [
            tournamentModeSettingsRepository,
          ],
          TournamentModeAssignmentState(),
        );

  final List<Competition> competitions;

  void tournamentModeChanged(Type? tournamentMode) {
    TournamentModeAssignmentState newState = state.copyWith(
      modeType: SelectionInput.dirty(value: tournamentMode),
      modeSettings: SelectionInput.dirty(
        value: _createDefaultSettings(tournamentMode),
      ),
    );

    emit(newState);
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
          id: 'id',
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
