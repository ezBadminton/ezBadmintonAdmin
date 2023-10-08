import 'package:collection/collection.dart';
import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/competition_management/models/playing_category.dart';

/// An ephemeral class creating information about the merge of
/// a list of competitions
class CompetitionMerge {
  CompetitionMerge({
    required this.competitions,
    required this.mergedCategory,
    Competition? primaryCompetition,
  }) : primaryCompetition =
            primaryCompetition ?? _getPrimaryCompetition(competitions) {
    _mergeCompetitions();
    _adoptRegistrations();
  }

  final List<Competition> competitions;
  final PlayingCategory mergedCategory;
  final Competition? primaryCompetition;

  late final Competition mergedCompetition;

  late final List<Team> adoptedTeams;
  late final List<Team> newTeams;
  late final List<Team> deletedTeams;

  void _mergeCompetitions() {
    if (primaryCompetition != null) {
      mergedCompetition = primaryCompetition!.copyWith(
        ageGroup: mergedCategory.ageGroup,
        playingLevel: mergedCategory.playingLevel,
      );
    } else {
      mergedCompetition = Competition.newCompetition(
        teamSize: competitions.first.teamSize,
        genderCategory: competitions.first.genderCategory,
        ageGroup: mergedCategory.ageGroup,
        playingLevel: mergedCategory.playingLevel,
      );
    }
  }

  /// Adopt the registrations from the [competitions] by marking them
  /// as directly adopted, newly created or deleted.
  void _adoptRegistrations() {
    List<Team> allTeams = competitions
        .map((c) => c.registrations)
        .expand((registrations) => registrations)
        .toList();

    Set<Player> allPlayers = allTeams.expand((team) => team.players).toSet();

    // First pass: Adopt all teams from the full list that don't
    // cause a Player to be registered twice
    adoptedTeams = [];
    Set<Player> adoptedPlayers = {};
    for (Team team in allTeams) {
      bool notYetAdopted =
          team.players.firstWhereOrNull((p) => adoptedPlayers.contains(p)) ==
              null;
      if (notYetAdopted) {
        adoptedTeams.add(team);
        adoptedPlayers.addAll(team.players);
      }
    }

    // Second pass: Create a new Team for each player that was not adopted
    // in the first pass.
    Set<Player> unadoptedPlayers = allPlayers.difference(adoptedPlayers);
    newTeams = [
      for (Player player in unadoptedPlayers) Team.newTeam(players: [player]),
    ];

    // Third pass: Mark the unadopted Teams for deletion.
    deletedTeams =
        allTeams.whereNot((team) => adoptedTeams.contains(team)).toList();
  }

  /// Returns the primary competition which the others will be merged into.
  ///
  /// If no primary one can be chosen null is returned and the merged
  /// competition will be a newly created one.
  static Competition? _getPrimaryCompetition(List<Competition> competitions) {
    if (competitions.length == 1) {
      return competitions.first;
    }

    Competition? onlyOneWithRegistrations =
        competitions.where((c) => c.registrations.isNotEmpty).singleOrNull;
    if (onlyOneWithRegistrations != null) {
      return onlyOneWithRegistrations;
    }

    Competition? onlyOneWithDraw =
        competitions.where((c) => c.draw.isNotEmpty).singleOrNull;
    if (onlyOneWithDraw != null) {
      return onlyOneWithDraw;
    }

    Competition? onlyOneWithSeeds =
        competitions.where((c) => c.seeds.isNotEmpty).singleOrNull;
    if (onlyOneWithSeeds != null) {
      return onlyOneWithSeeds;
    }

    Competition? onlyOneWithTournamentMode = competitions
        .where((c) => c.tournamentModeSettings != null)
        .singleOrNull;

    return onlyOneWithTournamentMode;
  }
}
