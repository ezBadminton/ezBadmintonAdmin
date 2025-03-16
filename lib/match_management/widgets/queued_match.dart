import 'package:collection/collection.dart';
import 'package:ez_badminton_admin_app/court_management/cubit/cubit/court_cubit.dart';
import 'package:ez_badminton_admin_app/widgets/loading_screen/loading_screen.dart';
import 'package:ez_badminton_admin_app/widgets/tournament_context/tournament_context.dart';
import 'package:model_repository/model_repository.dart';
import 'package:ez_badminton_admin_app/assets/badminton_icons_icons.dart';
import 'package:ez_badminton_admin_app/home/cubit/tab_navigation_cubit.dart';
import 'package:ez_badminton_admin_app/match_management/cubit/match_start_stop_cubit.dart';
import 'package:ez_badminton_admin_app/match_management/cubit/match_court_assignment_cubit.dart';
import 'package:ez_badminton_admin_app/match_management/cubit/match_queue_cubit.dart';
import 'package:ez_badminton_admin_app/match_management/result_entering/view/result_input_dialog.dart';
import 'package:ez_badminton_admin_app/match_management/widgets/call_out_script.dart';
import 'package:ez_badminton_admin_app/widgets/countdown/countdown.dart';
import 'package:ez_badminton_admin_app/widgets/match_info/match_info.dart';
import 'package:ez_badminton_admin_app/widgets/match_label/match_label.dart';
import 'package:ez_badminton_admin_app/widgets/minutes_timer/minutes_timer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:ez_badminton_admin_app/display_strings/display_strings.dart'
    as display_strings;

class WaitingMatch extends StatelessWidget {
  const WaitingMatch({super.key});

  @override
  Widget build(BuildContext context) {
    var match = context.readScheduledMatch();

    return QueuedMatchCard(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: MatchInfo(),
          ),
          MatchupLabel(),
          Expanded(
            child: Align(
              alignment: AlignmentDirectional.centerEnd,
              child: Padding(
                padding: const EdgeInsets.only(right: 10.0),
                child: switch (match.status) {
                  ScheduleStatus.courtWait =>
                    _CourtAssignmentButton(match: match.match),
                  ScheduleStatus.playerRest => _RestBlockingInfo(),
                  ScheduleStatus.playerWait => _PlayerBlockingInfo(),
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
  const ReadyForCallOutMatch({super.key});

  @override
  Widget build(BuildContext context) {
    return QueuedMatchCard(
      child: Stack(
        children: [
          Center(
            child: Tooltip(
              waitDuration: const Duration(milliseconds: 500),
              richMessage: WidgetSpan(
                child: DefaultTextStyle.merge(
                  style: const TextStyle(color: Colors.white),
                  child: MatchInfo(dividerColor: Colors.white54),
                ),
              ),
              child: MatchupLabel(),
            ),
          ),
          Positioned(
            bottom: 0,
            top: 0,
            right: 6,
            child: Align(
              child: _CallOutButton(),
            ),
          ),
          Positioned(
            bottom: 0,
            top: 0,
            child: Align(
              child: _BackToWaitlistButton(),
            ),
          ),
        ],
      ),
    );
  }
}

class RunningMatch extends StatelessWidget {
  const RunningMatch({super.key});

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;

    var match = context.readMatch();

    return QueuedMatchCard(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MatchInfo(),
                const SizedBox(height: 7),
                if (match.endTime == null)
                  MinutesTimer(
                    timestamp: match.startTime!,
                    textStyle: const TextStyle(fontSize: 12),
                  )
                else
                  Text(
                    l10n.matchEnded,
                    style: const TextStyle(fontSize: 12),
                  ),
              ],
            ),
          ),
          MatchupLabel(),
          Expanded(
            child: Align(
              alignment: AlignmentDirectional.centerEnd,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _RunningMatchMenuButton(),
                  const SizedBox(width: 12),
                  _EnterResultButton(),
                  const SizedBox(width: 8),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

class QueuedMatchCard extends StatelessWidget {
  const QueuedMatchCard({
    required this.child,
    super.key,
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

class _CourtAssignmentButton extends StatelessWidget {
  const _CourtAssignmentButton({
    required this.match,
  });

  final TournamentMatch match;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MatchQueueCubit, MatchQueueState>(
      buildWhen: (previous, current) => previous.queueMode != current.queueMode,
      builder: (context, state) {
        return switch (state.queueMode) {
          QueueMode.manual => _ManualCourtAssignmentButton(match: match),
          QueueMode.autoCourtAssignment =>
            _AutoCourtAssignmentButton(match: match),
          QueueMode.auto => const _FullAutoSymbol(),
        };
      },
    );
  }
}

class _ManualCourtAssignmentButton extends StatelessWidget {
  const _ManualCourtAssignmentButton({
    required this.match,
  });

  final TournamentMatch match;

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
            reason: match,
            showBackButton: true,
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

class _AutoCourtAssignmentButton extends StatelessWidget {
  const _AutoCourtAssignmentButton({
    required this.match,
  });

  final TournamentMatch match;

  @override
  Widget build(BuildContext context) {
    var assignmentCubit = context.read<MatchCourtAssignmentCubit>();
    var l10n = AppLocalizations.of(context)!;

    return BlocBuilder<CourtCubit, CourtState>(
      builder: (context, state) {
        return LoadingScreen(
            loadingStatus: state.loadingStatus,
            builder: (context) {
              bool courtsAvailable =
                  state.occupied.length < state.getCollection<Court>().length;
              String tooltip =
                  courtsAvailable ? l10n.assignCourt : l10n.nOpenCourts(0);

              return Tooltip(
                message: tooltip,
                child: SizedBox.square(
                  dimension: 45,
                  child: ElevatedButton(
                    onPressed: courtsAvailable
                        ? () {
                            assignmentCubit.courtAutoAssignedToMatch(match);
                          }
                        : null,
                    style: ButtonStyle(
                      shape: MaterialStatePropertyAll(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14.0),
                        ),
                      ),
                      padding: const MaterialStatePropertyAll(EdgeInsets.zero),
                    ),
                    child: Stack(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                              bottom: 11, left: 4, right: 4),
                          child: Container(
                            decoration: const BoxDecoration(),
                            clipBehavior: Clip.hardEdge,
                            child: const SizedBox(
                              width: 26,
                              height: 20,
                              child: Icon(
                                BadmintonIcons.badminton_court_outline,
                                size: 26,
                              ),
                            ),
                          ),
                        ),
                        const Positioned(
                          bottom: -1,
                          left: 0,
                          right: 0,
                          child: Text(
                            'AUTO',
                            style: TextStyle(fontSize: 10),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            });
      },
    );
  }
}

class _FullAutoSymbol extends StatelessWidget {
  const _FullAutoSymbol();

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;

    return Tooltip(
      message: l10n.matchWaitsForCourt,
      child: SizedBox.square(
        dimension: 45,
        child: Card(
          margin: EdgeInsets.zero,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14.0),
          ),
          color: Theme.of(context).secondaryHeaderColor,
          child: Icon(
            Icons.hourglass_top_rounded,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(.6),
          ),
        ),
      ),
    );
  }
}

class _PlayerBlockingInfo extends StatelessWidget {
  const _PlayerBlockingInfo();

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;

    var match = context.readScheduledMatch();
    var planStore = context.read<ModelStore<TournamentPlan>>();

    var blocks = match.blockingPlayers;
    var blockingMatches = <MatchContext>[];
    for (var block in blocks.values) {
      if (block.blockingMatch != null) {
        var match = block.blockingMatch!;
        var tPlan = planStore.getModel(match.tournamentPlanId)!;
        var mContext = MatchContext(tournamentPlan: tPlan, match: match);
        blockingMatches.add(mContext);
      }
    }

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
        l10n.nBlockingPlayers(blocks.length),
        textAlign: TextAlign.end,
        style: const TextStyle(fontSize: 12),
      ),
    );
  }
}

class _RestBlockingInfo extends StatelessWidget {
  const _RestBlockingInfo();

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;

    var match = context.readScheduledMatch();

    return BlocBuilder<MatchQueueCubit, MatchQueueState>(
      builder: (context, state) {
        Map<Player, DateTime> restingDeadlines = Map.fromEntries(
          match.blockingPlayers.entries
              .where((e) => e.value.restUntil != null)
              .map((e) => MapEntry(e.key, e.value.restUntil!)),
        );

        DateTime latestRestDeadline = restingDeadlines.values.sorted().last;

        return Tooltip(
          richMessage: _createTooltip(restingDeadlines, l10n),
          child: Column(
            children: [
              Text('${l10n.playerRestTime}:'),
              Countdown(
                timestamp: latestRestDeadline,
              ),
            ],
          ),
        );
      },
    );
  }

  InlineSpan _createTooltip(
    Map<Player, DateTime> restingDeadlines,
    AppLocalizations l10n,
  ) {
    TextStyle tooltipStyle = const TextStyle(
      fontSize: 12,
      color: Colors.white,
    );

    List<Widget> playerNames = restingDeadlines.keys
        .map((p) => Text(
              display_strings.playerName(p),
              style: tooltipStyle,
            ))
        .toList();

    List<Widget> restTimes = restingDeadlines.values.map((t) {
      return Countdown(
        timestamp: t,
        textStyle: tooltipStyle,
      );
    }).toList();

    return WidgetSpan(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: playerNames,
          ),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: restTimes,
          ),
        ],
      ),
    );
  }
}

class _PlayerBlockingDialog extends StatelessWidget {
  const _PlayerBlockingDialog({
    required this.matches,
  });

  final List<MatchContext> matches;

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;

    return AlertDialog(
      title: Text(l10n.blockingGames(matches.length)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var mContext in matches) ...[
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
                  child: TournamentMatchContextSubtree.fromContext(
                    key: ValueKey('PlayerBlockingMatch-${mContext.match.id}'),
                    context: mContext,
                    child: MatchLabel(
                      opponentStyle: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 19,
                      ),
                      infoStyle: const TextStyle(fontSize: 14),
                    ),
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
  const _CallOutButton();

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;

    var tPlan = context.readTournamentPlan();
    var match = context.readMatch();

    return Tooltip(
      message: l10n.callOutMatch,
      child: SizedBox.square(
        dimension: 35,
        child: ElevatedButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (_) => CallOutScript(
                callOuts: [MatchContext(tournamentPlan: tPlan, match: match)],
                matchStartingCubit: context.read<MatchStartStopCubit>(),
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
  const _BackToWaitlistButton();

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;
    var courtAssignmentCubit = context.read<MatchCourtAssignmentCubit>();

    var match = context.readMatch();

    return BlocBuilder<MatchQueueCubit, MatchQueueState>(
      buildWhen: (previous, current) => previous.queueMode != current.queueMode,
      builder: (context, state) {
        if (state.queueMode == QueueMode.auto) {
          return const SizedBox();
        }

        return SizedBox.square(
          dimension: 35,
          child: Tooltip(
            message: l10n.backToWaitList,
            child: IconButton(
              onPressed: () =>
                  courtAssignmentCubit.courtAssignmentRevoked(match),
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
      },
    );
  }
}

class _EnterResultButton extends StatelessWidget {
  const _EnterResultButton();

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;

    var mContext = context.readMatchContext();

    return Tooltip(
      message: l10n.enterResult,
      child: SizedBox.square(
        dimension: 45,
        child: ElevatedButton(
          onPressed: () {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => TournamentMatchContextSubtree.fromContext(
                key: ValueKey('ResultInputMatch-${mContext.match.id}'),
                context: mContext,
                child: ResultInputDialog(),
              ),
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

class _RunningMatchMenuButton extends StatelessWidget {
  const _RunningMatchMenuButton();

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;
    var cubit = context.read<MatchStartStopCubit>();

    var match = context.readMatch();

    return PopupMenuButton<VoidCallback>(
      onSelected: (callback) => callback(),
      tooltip: '',
      splashRadius: 19,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: Icon(
          Icons.more_vert,
          color: Theme.of(context).primaryColor,
        ),
      ),
      itemBuilder: (context) => [
        if (match.endTime == null)
          PopupMenuItem(
            value: () => cubit.matchEnded(match),
            child: Text(l10n.unlockCourt),
          ),
        PopupMenuItem(
          value: () => cubit.matchCanceled(match),
          child: Text(
            l10n.cancelMatch,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ),
      ],
    );
  }
}
