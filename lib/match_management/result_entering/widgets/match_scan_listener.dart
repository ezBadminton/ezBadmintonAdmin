import 'package:collection/collection.dart';
import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/badminton_tournament_ops/badminton_match.dart';
import 'package:ez_badminton_admin_app/badminton_tournament_ops/cubit/tournament_progress_cubit.dart';
import 'package:ez_badminton_admin_app/match_management/result_entering/cubit/match_scan_listener_cubit.dart';
import 'package:ez_badminton_admin_app/match_management/result_entering/view/result_input_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// A global keyboard listener that forwards keyboard events to the
/// [MatchScanListenerCubit].
///
/// When the cubit emits a scanned [MatchData] object the corresponding
/// [BadmintonMatch] is found and if the match is currently in progress,
/// the [ResultInputDialog] for the match is popped up.
class MatchScanListener extends StatelessWidget {
  const MatchScanListener({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MatchScanListenerCubit(
        matchDataRepository: context.read<CollectionRepository<MatchData>>(),
      ),
      child: _MatchScanFocus(child: child),
    );
  }
}

class _MatchScanFocus extends StatelessWidget {
  const _MatchScanFocus({
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    var scannerCubit = context.read<MatchScanListenerCubit>();
    var progressCubit = context.read<TournamentProgressCubit>();

    return BlocListener<MatchScanListenerCubit, MatchScanListenerState>(
      listenWhen: (previous, current) => current.scannedMatch.value != null,
      listener: (context, state) {
        MatchData scannedMatchData = state.scannedMatch.value!;
        if (scannedMatchData.startTime == null ||
            scannedMatchData.sets.isNotEmpty) {
          return;
        }

        Iterable<BadmintonMatch> matches = progressCubit
            .state.runningTournaments.values
            .expand((t) => t.matches);

        BadmintonMatch? scannedMatch =
            matches.firstWhereOrNull((m) => m.matchData == scannedMatchData);

        if (scannedMatch == null) {
          return;
        }

        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => ResultInputDialog(
            match: scannedMatch,
            tournamentProgressCubit: progressCubit,
          ),
        );
      },
      child: Focus(
        onKeyEvent: (node, event) {
          scannerCubit.onKeyEvent(event);
          return KeyEventResult.ignored;
        },
        child: child,
      ),
    );
  }
}
