import 'dart:math';

import 'package:collection/collection.dart';
import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/collection_queries/collection_querier.dart';
import 'package:ez_badminton_admin_app/draw_management/utils/team_status.dart';
import 'package:ez_badminton_admin_app/draw_management/utils/tournament_draws.dart';
import 'package:ez_badminton_admin_app/utils/powers_of_two.dart';
import 'package:ez_badminton_admin_app/widgets/dialog_listener/cubit_mixin/dialog_cubit.dart';
import 'package:formz/formz.dart';

part 'drawing_state.dart';

class DrawingCubit extends CollectionQuerierCubit<DrawingState>
    with DialogCubit {
  DrawingCubit({
    required Competition competition,
    required CollectionRepository<Competition> competitionRepository,
  }) : super(
          collectionRepositories: [
            competitionRepository,
          ],
          DrawingState(competition: competition),
        ) {
    subscribeToCollectionUpdates(
      competitionRepository,
      _onCompetitionCollectionUpdate,
    );
  }

  /// Make the draw using the existing [Competition.rngSeed]
  void makeDraw() async {
    if (state.formStatus == FormzSubmissionStatus.inProgress) {
      return;
    }
    emit(state.copyWith(formStatus: FormzSubmissionStatus.inProgress));

    FormzSubmissionStatus drawSuccess = await _draw(state.competition);

    emit(state.copyWith(formStatus: drawSuccess));
  }

  /// Make the draw with a newly created RNG seed
  void redraw() async {
    if (state.formStatus == FormzSubmissionStatus.inProgress) {
      return;
    }
    emit(state.copyWith(formStatus: FormzSubmissionStatus.inProgress));

    int newRngSeed = Random().nextInt(1 << 32);

    Competition newRngCompetition =
        state.competition.copyWith(rngSeed: newRngSeed);

    FormzSubmissionStatus drawSuccess = await _draw(newRngCompetition);

    emit(state.copyWith(formStatus: drawSuccess));
  }

  Future<FormzSubmissionStatus> _draw(Competition competition) async {
    if (competition.tournamentModeSettings == null) {
      return FormzSubmissionStatus.failure;
    }

    List<List<Team>> seededTiers = _getSeededTiers();

    List<Team> attendingTeams = seededTiers.expand((tier) => tier).toList();

    int minParticipants =
        minDrawParticipants(competition.tournamentModeSettings!);

    if (attendingTeams.length < minParticipants) {
      requestDialogChoice<void>(reason: minParticipants);
      return FormzSubmissionStatus.failure;
    }

    Random random = Random(competition.rngSeed);

    List<Team> draw = [
      for (List<Team> tier in seededTiers) ...tier..shuffle(random),
    ];

    Competition competitionWithDraw = competition.copyWith(draw: draw);

    Competition? updatedCompetition =
        await querier.updateModel(competitionWithDraw);
    if (updatedCompetition == null) {
      return FormzSubmissionStatus.failure;
    }

    return FormzSubmissionStatus.success;
  }

  /// Returns all registered teams sorted into seeded tiers.
  ///
  /// The unseeded teams are in the last tier.
  ///
  /// Teams with players that are not attending or do not have a partner are
  /// filtered.
  List<List<Team>> _getSeededTiers() {
    List<Team> seededTeams = state.competition.seeds;
    List<List<Team>> seededTiers =
        switch (state.competition.tournamentModeSettings!.seedingMode) {
      SeedingMode.single => _seedsToSingleTiers(seededTeams),
      SeedingMode.tiered => _seedsToTiers(seededTeams),
      SeedingMode.random => [seededTeams],
    };
    List<Team> normalTeams = state.competition.registrations
        .whereNot((t) => seededTeams.contains(t))
        .toList();

    seededTiers.add(normalTeams);

    List<List<Team>> attendingSeededTiers =
        seededTiers.map((tier) => _filterAttendingTeams(tier)).toList();

    return attendingSeededTiers;
  }

  List<Team> _filterAttendingTeams(List<Team> teams) {
    return teams
        .where((t) => teamStatus(t) == PlayerStatus.attending)
        .where((t) => t.players.length == state.competition.teamSize)
        .toList();
  }

  static List<List<Team>> _seedsToSingleTiers(List<Team> seededTeams) {
    return seededTeams.map((t) => [t]).toList();
  }

  static List<List<Team>> _seedsToTiers(List<Team> seededTeams) {
    List<List<Team>> tiers = [];

    for (int i = 0; i < seededTeams.length; i += 1) {
      int tier = _seedIndexToTier(i);
      if (tier + 1 > tiers.length) {
        tiers.add([]);
      }

      tiers[tier].add(seededTeams[i]);
    }

    return tiers;
  }

  static int _seedIndexToTier(int seedIndex) {
    if (seedIndex <= 1) {
      return seedIndex;
    } else {
      return previousPowerOfTwoExponent(seedIndex) + 1;
    }
  }

  void _onCompetitionCollectionUpdate(
    CollectionUpdateEvent<Competition> event,
  ) {
    if (event.model.id == state.competition.id) {
      emit(state.copyWith(competition: event.model));
    }
  }
}
