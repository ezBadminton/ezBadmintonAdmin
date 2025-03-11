import 'dart:math';

import 'package:model_repository/model_repository.dart';

/// Returns the minimum amount of players needed to make a draw for a tournament
/// with the given [modeSettings].
int minDrawParticipants(TournamentModeSettings modeSettings) {
  switch (modeSettings) {
    case RoundRobinSettings _:
    case SingleEliminationSettings _:
      return 2;
    case GroupKnockoutSettings settings:
      return max(settings.numQualifications, settings.numGroups);
    case DoubleEliminationSettings _:
    case SingleEliminationWithConsolationSettings _:
      return 3;
  }
}
