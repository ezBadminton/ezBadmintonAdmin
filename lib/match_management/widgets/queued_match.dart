import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/assets/badminton_icons_icons.dart';
import 'package:ez_badminton_admin_app/badminton_tournament_ops/badminton_match.dart';
import 'package:ez_badminton_admin_app/badminton_tournament_ops/cubit/tournament_progress_cubit.dart';
import 'package:ez_badminton_admin_app/home/cubit/tab_navigation_cubit.dart';
import 'package:ez_badminton_admin_app/match_management/cubit/call_out_cubit.dart';
import 'package:ez_badminton_admin_app/match_management/cubit/match_queue_cubit.dart';
import 'package:ez_badminton_admin_app/match_management/result_entering/view/result_input_dialog.dart';
import 'package:ez_badminton_admin_app/match_management/widgets/call_out_script.dart';
import 'package:ez_badminton_admin_app/widgets/competition_label/competition_label.dart';
import 'package:ez_badminton_admin_app/widgets/match_label/match_label.dart';
import 'package:ez_badminton_admin_app/widgets/minutes_timer/minutes_timer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:ez_badminton_admin_app/display_strings/display_strings.dart'
    as display_strings;

class WaitingMatch extends StatelessWidget {
  WaitingMatch({
    required this.match,
    required this.waitingStatus,
  }) : super(key: ValueKey('WaitingMatch-${match.matchData!.id}'));

  final BadmintonMatch match;
  final MatchWaitingStatus waitingStatus;

  @override
  Widget build(BuildContext context) {
    return _QueuedMatchCard(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: _MatchInfo(match: match),
          ),
          MatchupLabel(match: match),
          Expanded(
            child: Align(
              alignment: AlignmentDirectional.centerEnd,
              child: Padding(
                padding: const EdgeInsets.only(right: 10.0),
                child: switch (waitingStatus) {
                  MatchWaitingStatus.waitingForCourt =>
                    _CourtAssignmentButton(matchData: match.matchData!),
                  MatchWaitingStatus.waitingForPlayer =>
                    _PlayerBlockingInfo(match: match),
                  _ => const SizedBox(),
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ReadyForCallOutMatch extends StatelessWidget {
  ReadyForCallOutMatch({
    required this.match,
  }) : super(key: ValueKey('ReadyForCallOutMatch-${match.matchData!.id}'));

  final BadmintonMatch match;

  @override
  Widget build(BuildContext context) {
    return _QueuedMatchCard(
      child: Stack(
        children: [
          Center(
            child: Tooltip(
              waitDuration: const Duration(milliseconds: 500),
              richMessage: WidgetSpan(
                child: DefaultTextStyle.merge(
                  style: const TextStyle(color: Colors.white),
                  child: _MatchInfo(
                    match: match,
                    dividerColor: Colors.white54,
                  ),
                ),
              ),
              child: MatchupLabel(match: match),
            ),
          ),
          Positioned(
            bottom: 0,
            top: 0,
            right: 6,
            child: Align(
              child: _CallOutButton(match: match),
            ),
          ),
          Positioned(
            bottom: 0,
            top: 0,
            child: Align(
              child: _BackToWaitlistButton(matchData: match.matchData!),
            ),
          ),
        ],
      ),
    );
  }
}

class RunningMatch extends StatelessWidget {
  RunningMatch({
    required this.match,
  }) : super(key: ValueKey('RunningMatch-${match.matchData!.id}'));

  final BadmintonMatch match;

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;

    return _QueuedMatchCard(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: _MatchInfo(match: match),
          ),
          MatchupLabel(match: match),
          Expanded(
            child: Align(
              alignment: AlignmentDirectional.centerEnd,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(l10n.playingTime),
                  MinutesTimer(timestamp: match.startTime!),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.only(right: 12.0),
                    child: _EnterResultButton(match: match),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

class _QueuedMatchCard extends StatelessWidget {
  const _QueuedMatchCard({
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(7.0),
        side: BorderSide(
          color: Theme.of(context).colorScheme.onSurface.withOpacity(.33),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 8.0),
        child: child,
      ),
    );
  }
}

class _MatchInfo extends StatelessWidget {
  const _MatchInfo({
    required this.match,
    this.dividerColor,
  });

  final BadmintonMatch match;

  final Color? dividerColor;

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;
    String? roundName = display_strings.matchRoundName(l10n, match);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CompetitionLabel(
          competition: match.competition,
          abbreviated: true,
          playingLevelMaxWidth: 50,
          textStyle: const TextStyle(fontSize: 12),
          dividerPadding: 3,
          dividerSize: 5,
          dividerColor: dividerColor,
        ),
        if (roundName != null) ...[
          const SizedBox(height: 7),
          Text(
            roundName,
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ],
    );
  }
}

class _CourtAssignmentButton extends StatelessWidget {
  const _CourtAssignmentButton({
    required this.matchData,
  });

  final MatchData matchData;

  @override
  Widget build(BuildContext context) {
    var navigationCubit = context.read<TabNavigationCubit>();
    var l10n = AppLocalizations.of(context)!;

    return Tooltip(
      message: l10n.assignCourt,
      child: SizedBox.square(
        dimension: 45,
        child: ElevatedButton(
          onPressed: () => navigationCubit.tabChanged(
            2,
            reason: matchData,
          ),
          style: ButtonStyle(
            shape: MaterialStatePropertyAll(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14.0),
              ),
            ),
            padding: const MaterialStatePropertyAll(EdgeInsets.zero),
          ),
          child: const Icon(
            BadmintonIcons.badminton_court_outline,
            size: 30,
          ),
        ),
      ),
    );
  }
}

class _PlayerBlockingInfo extends StatelessWidget {
  const _PlayerBlockingInfo({
    required this.match,
  });

  final BadmintonMatch match;

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;

    return BlocBuilder<TournamentProgressCubit, TournamentProgressState>(
      builder: (context, state) {
        List<Player> playersOfMatch = match.getPlayersOfMatch().toList();
        Map<Player, BadmintonMatch> blockingPlayers = Map.fromEntries(
          state.playingPlayers.entries
              .where((entry) => playersOfMatch.contains(entry.key)),
        );

        Set<BadmintonMatch> blockingMatches = blockingPlayers.values.toSet();

        return TextButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => _PlayerBlockingDialog(
                matches: blockingMatches,
              ),
            );
          },
          child: Text(
            l10n.nBlockingPlayers(blockingPlayers.length),
            textAlign: TextAlign.end,
            style: const TextStyle(fontSize: 12),
          ),
        );
      },
    );
  }
}

class _PlayerBlockingDialog extends StatelessWidget {
  const _PlayerBlockingDialog({
    required this.matches,
  });

  final Set<BadmintonMatch> matches;

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;

    return AlertDialog(
      title: Text(l10n.blockingGames(matches.length)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (BadmintonMatch match in matches) ...[
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(7.0),
                  side: BorderSide(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(.33),
                    width: 1,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: MatchLabel(
                    match: match,
                    opponentStyle: const TextStyle(fontSize: 19),
                    infoStyle: const TextStyle(fontSize: 14),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.confirm),
        ),
      ],
    );
  }
}

class _CallOutButton extends StatelessWidget {
  const _CallOutButton({
    required this.match,
  });

  final BadmintonMatch match;

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;

    return Tooltip(
      message: l10n.callOutMatch,
      child: SizedBox.square(
        dimension: 35,
        child: ElevatedButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (_) => CallOutScript(
                callOuts: [match],
                callOutCubit: context.read<CallOutCubit>(),
              ),
            );
          },
          style: const ButtonStyle(
            shape: MaterialStatePropertyAll(CircleBorder()),
            padding: MaterialStatePropertyAll(EdgeInsets.zero),
          ),
          child: const Icon(Icons.campaign),
        ),
      ),
    );
  }
}

class _BackToWaitlistButton extends StatelessWidget {
  const _BackToWaitlistButton({
    required this.matchData,
  });

  final MatchData matchData;

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;
    var cancelingCubit = context.read<CallOutCubit>();

    return SizedBox.square(
      dimension: 35,
      child: Tooltip(
        message: l10n.backToWaitList,
        child: IconButton(
          onPressed: () => cancelingCubit.callOutCanceled(matchData),
          style: const ButtonStyle(
            shape: MaterialStatePropertyAll(CircleBorder()),
            padding: MaterialStatePropertyAll(EdgeInsets.zero),
          ),
          splashRadius: 18,
          icon: const Icon(
            Icons.arrow_back,
            size: 18,
          ),
        ),
      ),
    );
  }
}

class _EnterResultButton extends StatelessWidget {
  const _EnterResultButton({
    required this.match,
  });

  final BadmintonMatch match;

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;

    return Tooltip(
      message: l10n.enterResult,
      child: SizedBox.square(
        dimension: 45,
        child: ElevatedButton(
          onPressed: () {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => ResultInputDialog(match: match),
            );
          },
          style: ButtonStyle(
            shape: MaterialStatePropertyAll(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14.0),
              ),
            ),
            padding: const MaterialStatePropertyAll(EdgeInsets.zero),
          ),
          child: const Icon(
            Icons.scoreboard_outlined,
            size: 32,
          ),
        ),
      ),
    );
  }
}
