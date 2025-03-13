import 'package:collection/collection.dart';
import 'package:ez_badminton_admin_app/tournament_plans/cubit/tournament_plan_cubit.dart';
import 'package:ez_badminton_admin_app/widgets/tournament_context/tournament_context.dart';
import 'package:model_repository/model_repository.dart';
import 'package:ez_badminton_admin_app/match_management/result_entering/cubit/match_scan_listener_cubit.dart';
import 'package:ez_badminton_admin_app/match_management/result_entering/view/result_input_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// A global keyboard listener that forwards keyboard events to the
/// [MatchScanListenerCubit].
///
/// When the cubit emits a scanned [TournamentMatch] object the corresponding
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
        matchDataRepository: context.read<ModelStore<TournamentMatch>>(),
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
    var planCubit = context.read<TournamentPlanCubit>();

    return BlocListener<MatchScanListenerCubit, MatchScanListenerState>(
      listenWhen: (previous, current) => current.scannedMatch.value != null,
      listener: (context, state) {
        TournamentMatch scannedTournamentMatch = state.scannedMatch.value!;
        if (scannedTournamentMatch.startTime == null ||
            scannedTournamentMatch.sets.isNotEmpty) {
          return;
        }

        Competition? competition;
        for (var plan in planCubit.state.runningTournaments.values) {
          var matches = plan.tournament.rounds.flattened;
          var match =
              matches.firstWhereOrNull((m) => m == scannedTournamentMatch);
          if (match != null) {
            competition = plan.competition;
            break;
          }
        }

        if (competition == null) {
          return;
        }

        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => TournamentMatchContextSubtree(
            key: ValueKey('QrScannedMatch-${scannedTournamentMatch.id}'),
            competition: competition!,
            match: scannedTournamentMatch,
            child: ResultInputDialog(),
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
