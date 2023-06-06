import 'package:collection_repository/collection_repository.dart';

class CompetitionRegistration {
  /// An ephemeral data structure representing the registration of a [team]
  /// in a [competition].
  CompetitionRegistration({
    required this.competition,
    required this.team,
  });

  CompetitionRegistration.fromCompetition({
    required this.competition,
    required Player player,
  }) : team = competition.registrations
            .where((team) => team.players.contains(player))
            .first;

  final Competition competition;
  final Team team;
}
