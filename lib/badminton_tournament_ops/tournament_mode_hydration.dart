// Functions to instantiate and "hydrate" TournamentMode objects with
// seeding, drawing and match data.

import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/badminton_tournament_ops/badminton_tournament_modes.dart';
import 'package:tournament_mode/tournament_mode.dart';

/// Create the [TournamentMode] according to the [settings]' type and with the
/// given [draw].
///
/// The two arguments usually come from [Competition.tournamentModeSettings] and
/// [Competition.draw] to create the tournament mode for a given [Competition].
TournamentMode createTournamentMode(
  TournamentModeSettings settings,
  List<Team> draw,
) {
  DrawSeeds<Team> entries = DrawSeeds(draw);

  TournamentMode tournament = switch (settings) {
    SingleEliminationSettings _ =>
      BadmintonSingleElimination(seededEntries: entries),
    RoundRobinSettings settings =>
      BadmintonRoundRobin.fromSettings(entries: entries, settings: settings),
    GroupKnockoutSettings settings =>
      BadmintonGroupKnockout.fromSettings(entries: entries, settings: settings),
  };

  return tournament;
}
