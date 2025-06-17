import 'package:model_repository/model_repository.dart';
import 'package:ez_badminton_admin_app/collection_queries/collection_querier.dart';
import 'package:ez_badminton_admin_app/utils/list_extension/list_extension.dart';
import 'package:formz/formz.dart';

part 'seeding_state.dart';

class SeedingCubit extends CollectionQuerierCubit<SeedingState> {
  SeedingCubit({
    required Competition competition,
    required ModelStore<Competition> competitionStore,
    required ModelStore<Player> playerStore,
    required this.seedsEndpoint,
  }) : super(
          modelStores: [
            competitionStore,
            playerStore,
          ],
          SeedingState(competition: competition),
        ) {
    subscribeToCollectionUpdates(
      competitionStore,
      _onCompetitionCollectionUpdate,
    );
    subscribeToCollectionUpdates(
      playerStore,
      _onPlayerCollectionUpdate,
    );
  }

  final SetSeedsEndpoint seedsEndpoint;

  void seedingToggled(Team team) async {
    if (state.formStatus == FormzSubmissionStatus.inProgress) {
      return;
    }
    emit(state.copyWith(formStatus: FormzSubmissionStatus.inProgress));

    FormzSubmissionStatus formStatus;
    if (state.competition.seeds.contains(team)) {
      formStatus = await _removeTeamFromSeeds(team);
    } else {
      formStatus = await _addTeamToSeeds(team);
    }

    emit(state.copyWith(formStatus: formStatus));
  }

  void seedsReordered(int from, int to) async {
    if (state.formStatus == FormzSubmissionStatus.inProgress ||
        from == to ||
        to >= state.competition.seeds.length) {
      return;
    }
    emit(state.copyWith(formStatus: FormzSubmissionStatus.inProgress));

    List<Team> reorderedSeeds = state.competition.seeds.moveItem(from, to);

    FormzSubmissionStatus formStatus = await _updateSeeds(reorderedSeeds);

    emit(state.copyWith(formStatus: formStatus));
  }

  Future<FormzSubmissionStatus> _addTeamToSeeds(Team team) async {
    List<Team> seeds = List.of(state.competition.seeds);
    seeds.add(team);

    return _updateSeeds(seeds);
  }

  Future<FormzSubmissionStatus> _removeTeamFromSeeds(Team team) async {
    List<Team> seeds = List.of(state.competition.seeds);
    seeds.remove(team);

    return _updateSeeds(seeds);
  }

  Future<FormzSubmissionStatus> _updateSeeds(List<Team> seeds) async {
    try {
      await seedsEndpoint.post(
          pathParams: {"competition": state.competition.id},
          body: {"seeds": seeds.map((t) => t.id).toList()});
      return FormzSubmissionStatus.success;
    } catch (_) {
      return FormzSubmissionStatus.failure;
    }
  }

  void _onCompetitionCollectionUpdate(
    CollectionUpdateEvent<Competition> event,
  ) {
    if (event.model == state.competition) {
      emit(state.copyWith(competition: event.model));
    }
  }

  void _onPlayerCollectionUpdate(
    CollectionUpdateEvent<Player> event,
  ) {
    List<Player> players =
        state.competition.registrations.expand((team) => team.players).toList();
    if (players.contains(event.model)) {
      emit(state);
    }
  }

  @override
  void onCollectionUpdate(List<List<Model>> collections,
      CollectionUpdateEvent<Model>? updateEvent) {}
}
