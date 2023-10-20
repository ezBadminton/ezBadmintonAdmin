import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/assets/badminton_icons_icons.dart';
import 'package:ez_badminton_admin_app/badminton_tournament_ops/badminton_match.dart';
import 'package:ez_badminton_admin_app/home/cubit/tab_navigation_cubit.dart';
import 'package:ez_badminton_admin_app/match_management/cubit/call_out_cubit.dart';
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
  }) : super(key: ValueKey('WaitingMatch-${match.matchData!.id}'));

  final BadmintonMatch match;

  @override
  Widget build(BuildContext context) {
    return _QueuedMatchCard(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: _MatchInfo(match: match),
          ),
          MatchLabel(match: match),
          if (match.isPlayable && match.court == null)
            Expanded(
              child: Align(
                alignment: AlignmentDirectional.center,
                child: _CourtAssignmentButton(matchData: match.matchData!),
              ),
            )
          else
            const Expanded(child: Placeholder(fallbackHeight: 70)),
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
              child: MatchLabel(match: match),
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
          MatchLabel(match: match),
          Expanded(
            child: Align(
              alignment: AlignmentDirectional.centerEnd,
              child: Column(
                children: [
                  Text(l10n.playingTime),
                  MinutesTimer(timestamp: match.startTime!),
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
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
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
          style: const ButtonStyle(
            shape: MaterialStatePropertyAll(CircleBorder()),
            padding: MaterialStatePropertyAll(EdgeInsets.zero),
          ),
          child: const Icon(
            BadmintonIcons.badminton_court_outline,
            size: 28,
          ),
        ),
      ),
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
