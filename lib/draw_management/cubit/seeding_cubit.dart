import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/collection_queries/collection_querier.dart';
import 'package:formz/formz.dart';

part 'seeding_state.dart';

class SeedingCubit extends CollectionQuerierCubit<SeedingState> {
  SeedingCubit({
    required Competition competition,
    required CollectionRepository<Competition> competitionRepository,
  }) : super(
          collectionRepositories: [
            competitionRepository,
          ],
          SeedingState(competition: competition),
        ) {
    subscribeToCollectionUpdates(
      competitionRepository,
      _onCompetitionCollectionUpdate,
    );
  }

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

    Team reordered = state.competition.seeds[from];
    if (to > from) {
      to += 1;
    }
    List<Team> reorderedSeeds = List.of(state.competition.seeds)
      ..insert(to, reordered);
    if (to < from) {
      from += 1;
    }
    reorderedSeeds.removeAt(from);

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
    Competition competitionWithNewSeeds =
        state.competition.copyWith(seeds: seeds);

    Competition? updatedCompetition =
        await querier.updateModel(competitionWithNewSeeds);

    if (updatedCompetition == null) {
      return FormzSubmissionStatus.failure;
    }

    return FormzSubmissionStatus.success;
  }

  void _onCompetitionCollectionUpdate(
    CollectionUpdateEvent<Competition> event,
  ) {
    if (event.model.id == state.competition.id) {
      emit(state.copyWith(competition: event.model));
    }
  }
}
