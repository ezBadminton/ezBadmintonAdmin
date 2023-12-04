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
  }) : super(
          matcher: _matcher,
          finalRanking: BadmintonRoundRobinRanking(),
        ) {
    this.competition = competition;
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
    required Competition competition,
  }) : super(
          roundRobinBuilder: (entries) => BadmintonRoundRobin(
            entries: entries,
            passes: 1,
            competition: competition,
          ),
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
    required super.qualificationsPerGroup,
    required Competition competition,
  }) : super(
          groupPhaseBuilder: (entries, numGroups) => BadmintonGroupPhase(
            entries: entries,
            numGroups: numGroups,
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
        (m) => m.matchData!.startTime != null,
      ) !=
      null;

  BadmintonGroupKnockout.fromCompetition({
    required Ranking<Team> entries,
    required Competition competition,
  }) : this(
          entries: entries,
          numGroups: _getTournamentSettings<GroupKnockoutSettings>(competition)
              .numGroups,
          qualificationsPerGroup:
              _getTournamentSettings<GroupKnockoutSettings>(competition)
                  .qualificationsPerGroup,
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
        .where((m) => m.inProgress || m.isCompleted)
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
