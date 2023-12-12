import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/badminton_tournament_ops/cubit/tournament_progress_cubit.dart';

mixin MatchCancelingMixin {
  /// Cancels a match before it has its score recorded.
  ///
  /// When the match already ended and [unassignCourt] is false,
  /// it is attempted to restore the court assignment. Should the court already
  /// be assigned to a new match or should the court have been deleted,
  /// the match gets no court and needs to be assigned to a new court.
  MatchData cancelMatch(
    MatchData matchData,
    TournamentProgressState tournamentProgressState, {
    bool unassignCourt = false,
  }) {
    assert(matchData.sets.isEmpty);

    MatchData matchDataWithCancellation = matchData.copyWith(
      startTime: null,
      endTime: null,
    );

    if (unassignCourt || matchData.court == null) {
      matchDataWithCancellation = matchDataWithCancellation.copyWith(
        court: null,
        courtAssignmentTime: null,
      );
    } else if (matchData.endTime != null) {
      Court courtOfMatch = matchData.court!;

      // Revoke court from the canceled match if it is not open
      if (!tournamentProgressState.openCourts.contains(courtOfMatch)) {
        matchDataWithCancellation = matchDataWithCancellation.copyWith(
          court: null,
          courtAssignmentTime: null,
        );
      }
    }

    return matchDataWithCancellation;
  }
}
