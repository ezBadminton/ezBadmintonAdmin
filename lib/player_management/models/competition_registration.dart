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

  Player? get partner {
    assert(team.players.contains(player));
    return team.players.whereNot((p) => p == player).firstOrNull;
  }
}
