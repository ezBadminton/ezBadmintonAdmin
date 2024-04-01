import 'package:collection/collection.dart';
import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/badminton_tournament_ops/badminton_match.dart';
import 'package:ez_badminton_admin_app/badminton_tournament_ops/badminton_round_robin_ranking.dart';
import 'package:tournament_mode/tournament_mode.dart';

BadmintonMatch _matcher(MatchParticipant<Team> a, MatchParticipant<Team> b) =>
    BadmintonMatch(a, b);

mixin BadmintonTournamentMode
    on TournamentMode<Team, List<MatchSet>, BadmintonMatch> {
  late final Competition competition;
}

typedef BadmintonTournamentRound = TournamentRound<BadmintonMatch>;

S _getTournamentSettings<S extends TournamentModeSettings>(
  Competition competition,
) {
  return competition.tournamentModeSettings as S;
}

class BadmintonSingleElimination
    extends SingleElimination<Team, List<MatchSet>, BadmintonMatch>
    with BadmintonTournamentMode {
  BadmintonSingleElimination({
    required super.seededEntries,
    required Competition competition,
  }) : super(matcher: _matcher) {
    this.competition = competition;
  }
}

class BadmintonRoundRobin
    extends RoundRobin<Team, List<MatchSet>, BadmintonMatch>
    with BadmintonTournamentMode {
  BadmintonRoundRobin({
    required super.entries,
    required super.passes,
    required Competition competition,
    int requiredUntiedRanks = 0,
  }) : super(
          matcher: _matcher,
          finalRanking: BadmintonRoundRobinRanking(),
        ) {
    this.competition = competition;
    finalRanking.requiredUntiedRanks = requiredUntiedRanks;
  }

  BadmintonRoundRobin.fromCompetition({
    required Ranking<Team> entries,
    required Competition competition,
  }) : this(
          entries: entries,
          passes:
              _getTournamentSettings<RoundRobinSettings>(competition).passes,
          competition: competition,
        );
}

class BadmintonGroupPhase extends GroupPhase<Team, List<MatchSet>,
    BadmintonMatch, BadmintonRoundRobin> with BadmintonTournamentMode {
  BadmintonGroupPhase({
    required super.entries,
    required super.numGroups,
    required int numQualifications,
    required Competition competition,
  }) : super(
          roundRobinBuilder: (entries) => BadmintonRoundRobin(
            entries: entries,
            passes: 1,
            competition: competition,
            requiredUntiedRanks: (numQualifications / numGroups).ceil(),
          ),
          crossGroupRanking: BadmintonRoundRobinRanking(),
          numQualifications: numQualifications,
        ) {
    this.competition = competition;
  }
}

class BadmintonGroupKnockout extends GroupKnockout<
    Team,
    List<MatchSet>,
    BadmintonMatch,
    BadmintonRoundRobin,
    BadmintonGroupPhase,
    BadmintonSingleElimination> with BadmintonTournamentMode {
  BadmintonGroupKnockout({
    required super.entries,
    required super.numGroups,
    required super.numQualifications,
    required Competition competition,
  }) : super(
          groupPhaseBuilder: (entries, numGroups) => BadmintonGroupPhase(
            entries: entries,
            numGroups: numGroups,
            numQualifications: numQualifications,
            competition: competition,
          ),
          singleEliminationBuilder: (seededEntries) =>
              BadmintonSingleElimination(
            seededEntries: seededEntries,
            competition: competition,
          ),
        ) {
    this.competition = competition;
  }

  bool get hasKnockoutStarted =>
      knockoutPhase.matches.firstWhereOrNull(
        (m) => m.matchData?.startTime != null,
      ) !=
      null;

  BadmintonGroupKnockout.fromCompetition({
    required Ranking<Team> entries,
    required Competition competition,
  }) : this(
          entries: entries,
          numGroups: _getTournamentSettings<GroupKnockoutSettings>(competition)
              .numGroups,
          numQualifications:
              _getTournamentSettings<GroupKnockoutSettings>(competition)
                  .numQualifications,
          competition: competition,
        );

  @override
  List<BadmintonMatch> getEditableMatches() {
    if (!hasKnockoutStarted) {
      return groupPhase.getEditableMatches();
    } else {
      return knockoutPhase.getEditableMatches();
    }
  }

  @override
  List<BadmintonMatch> withdrawPlayer(Team player) {
    // While the knock out phase has not started yet, the group walkovers are
    // forced even if the group matches have been completed.
    if (!hasKnockoutStarted) {
      return groupPhase.withdrawPlayer(player, true);
    } else {
      return knockoutPhase.withdrawPlayer(player);
    }
  }

  @override
  List<BadmintonMatch> reenterPlayer(Team player) {
    Set<Team> groupOfPlayer = groupPhase.groupRoundRobins
        .map((g) => g.participants.map((p) => p.resolvePlayer()!))
        .firstWhere((g) => g.contains(player))
        .toSet();

    Set<Team> teamsInKnockout = knockoutPhase.matches
        .where((m) => m.startTime != null)
        .expand((m) => [m.a.resolvePlayer()!, m.b.resolvePlayer()!])
        .toSet();

    bool groupIsInKnockout =
        groupOfPlayer.intersection(teamsInKnockout).isNotEmpty;

    if (groupIsInKnockout) {
      return knockoutPhase.reenterPlayer(player);
    } else {
      return groupPhase.reenterPlayer(player);
    }
  }
}

class BadmintonDoubleElimination extends DoubleElimination<Team, List<MatchSet>,
    BadmintonMatch, BadmintonSingleElimination> with BadmintonTournamentMode {
  BadmintonDoubleElimination({
    required super.seededEntries,
    required Competition competition,
  }) : super(
          singleEliminationBuilder: (entries) => BadmintonSingleElimination(
            seededEntries: entries,
            competition: competition,
          ),
        ) {
    this.competition = competition;
  }
}

class BadmintonSingleEliminationWithConsolation
    extends SingleEliminationWithConsolation<
        Team,
        List<MatchSet>,
        BadmintonMatch,
        BadmintonSingleElimination> with BadmintonTournamentMode {
  BadmintonSingleEliminationWithConsolation({
    required super.seededEntries,
    required Competition competition,
    required super.numConsolationRounds,
    required super.placesToPlayOut,
  }) : super(
          singleEliminationBuilder: (entries) => BadmintonSingleElimination(
            seededEntries: entries,
            competition: competition,
          ),
        ) {
    this.competition = competition;
  }

  BadmintonSingleEliminationWithConsolation.fromCompetition({
    required Ranking<Team> seededEntries,
    required Competition competition,
  }) : this(
          seededEntries: seededEntries,
          competition: competition,
          numConsolationRounds:
              _getTournamentSettings<SingleEliminationWithConsolationSettings>(
            competition,
          ).numConsolationRounds,
          placesToPlayOut:
              _getTournamentSettings<SingleEliminationWithConsolationSettings>(
            competition,
          ).placesToPlayOut,
        );
}
