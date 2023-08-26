import 'package:collection/collection.dart';
import 'package:tournament_mode/src/tournament_match.dart';

/// A tournament mode made up of specifically chained stages of matches.
abstract class TournamentMode<P, S> {
  /// All matches that are played in this mode.
  List<TournamentMatch<P, S>> get matches;

  /// The [matches] grouped into stages.
  /// Every match is part of exactly one stage.
  ///
  /// A stage is a set of matches that can be played in parallel
  /// given the previous stage has completed. The list's order reflects the
  /// order of the stages.
  List<List<TournamentMatch<P, S>>> get stages;

  /// Returns the earliest stage that still has unfinished matches
  ///
  /// Returns `-1` if all matches are completed.
  int ongoingStage() {
    for (int i = 0; i < stages.length; i += 1) {
      bool ongoing =
          stages[i].firstWhereOrNull((match) => !match.isCompleted) != null;
      if (ongoing) {
        return i;
      }
    }

    return -1;
  }

  /// Returns the latest stage that already has one or more matches in progress
  /// or completed.
  ///
  /// Returns `0` if no matches have been started.
  int latestOngoingStage() {
    for (int i = stages.length - 1; i >= 0; i -= 1) {
      bool inProgress =
          stages[i].firstWhereOrNull((match) => match.startTime != null) !=
              null;
      if (inProgress) {
        return i;
      }
    }

    return 0;
  }

  /// Returns how many stages are currently in progress at once.
  ///
  /// This is useful for scheduling (e.g. a group phase) to not make the
  /// progress between the stages too unbalanced.
  int stageLag() {
    if (isCompleted()) {
      return 0;
    }
    return latestOngoingStage() - ongoingStage() + 1;
  }

  /// Returns wheter all [matches] are completed.
  bool isCompleted() {
    return matches.firstWhereOrNull((match) => !match.isCompleted) == null;
  }
}
