import 'package:collection/collection.dart';
import 'package:model_repository/model_repository.dart';

class CompetitionRegistrationDep {
  /// An ephemeral data structure representing the registration of a [team]
  /// in a [competition].
  CompetitionRegistrationDep({
    required this.player,
    required this.competition,
    required this.team,
  }) : seed = _getSeed(competition, team);

  CompetitionRegistrationDep.fromCompetition({
    required this.player,
    required this.competition,
  })  : team = _getTeamOfPlayer(competition, player),
        seed = _getSeed(competition, _getTeamOfPlayer(competition, player));

  final Player player;
  final Competition competition;
  final Team team;

  final int? seed;

  /// Returns null if the player is alone on the team
  Player? get partner {
    assert(team.players.contains(player));
    return team.players.whereNot((p) => p == player).firstOrNull;
  }

  /// Returns a [Team] if the partner of the [player] is already on a [Team].
  ///
  /// This can happen when two players were registered on solo teams and are now
  /// being registered as partners.
  Team? getPartnerTeam() {
    if (partner == null || competition.teamSize == 1) {
      return null;
    }
    return competition.registrations.firstWhereOrNull(
      (t) => t.players.length == 1 && t.players[0] == partner,
    );
  }

  CompetitionRegistrationDep copyWith({
    Player? player,
    Competition? competition,
    Team? team,
  }) =>
      CompetitionRegistrationDep(
        player: player ?? this.player,
        competition: competition ?? this.competition,
        team: team ?? this.team,
      );

  static Team _getTeamOfPlayer(Competition competition, Player player) {
    return competition.registrations
        .where((team) => team.players.contains(player))
        .first;
  }

  static int? _getSeed(Competition competition, Team team) {
    if (competition.seeds.contains(team)) {
      return competition.seeds.indexOf(team);
    } else {
      return null;
    }
  }
}
