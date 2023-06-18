import 'package:collection/collection.dart';
import 'package:collection_repository/collection_repository.dart';

class CompetitionRegistration {
  /// An ephemeral data structure representing the registration of a [team]
  /// in a [competition].
  CompetitionRegistration({
    required this.player,
    required this.competition,
    required this.team,
  });

  CompetitionRegistration.fromCompetition({
    required this.player,
    required this.competition,
  }) : team = competition.registrations
            .where((team) => team.players.contains(player))
            .first;

  final Player player;
  final Competition competition;
  final Team team;

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
    if (partner != null) {
      return competition.registrations
          .where((t) => t.players.contains(partner))
          .firstOrNull;
    } else {
      return null;
    }
  }

  CompetitionRegistration copyWith({
    Player? player,
    Competition? competition,
    Team? team,
  }) =>
      CompetitionRegistration(
        player: player ?? this.player,
        competition: competition ?? this.competition,
        team: team ?? this.team,
      );
}
