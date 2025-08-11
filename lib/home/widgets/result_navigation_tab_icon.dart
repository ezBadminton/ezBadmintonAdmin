import 'package:ez_badminton_admin_app/home/widgets/navigation_tab_icon.dart';
import 'package:ez_badminton_admin_app/tournament_plans/cubit/tournament_plan_cubit.dart';
import 'package:ez_badminton_admin_app/widgets/competition_label/competition_label.dart';
import 'package:ez_badminton_admin_app/widgets/speech_bubble/speech_bubble.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ez_badminton_admin_app/l10n/l10n.dart';
import 'package:model_repository/model_repository.dart';

/// The icon for the result tab.
///
/// It shows a notification warning the user of unbroken ties that are
/// blocking the tournament progress.
class ResultNavigationTabIcon extends StatefulWidget {
  const ResultNavigationTabIcon({
    super.key,
    required this.icon,
    required this.isTabSelected,
  });

  final IconData icon;

  final bool isTabSelected;

  @override
  State<ResultNavigationTabIcon> createState() =>
      _ResultNavigationTabIconState();
}

class _ResultNavigationTabIconState extends State<ResultNavigationTabIcon> {
  late List<TournamentPlan> tournamentsWithBlockingTies;
  bool _showNotification = false;

  @override
  void initState() {
    super.initState();
    tournamentsWithBlockingTies = [];
  }

  @override
  void didUpdateWidget(ResultNavigationTabIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.isTabSelected && widget.isTabSelected) {
      _showNotification = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;

    Widget? blockingTieNotification;
    if (_showNotification) {
      blockingTieNotification = MouseRegion(
        onEnter: (_) {
          setState(() {
            _showNotification = false;
          });
        },
        child: SpeechBubble(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.tournamentProgressBlocked),
                Text(l10n.tieBreakerRequired),
                const SizedBox(height: 10),
                for (TournamentPlan tPlan in tournamentsWithBlockingTies)
                  CompetitionLabel(competition: tPlan.competition),
              ],
            ),
          ),
        ),
      );
    }

    Widget? blockingTieNotificationIcon;
    if (tournamentsWithBlockingTies.isNotEmpty) {
      blockingTieNotificationIcon = MouseRegion(
        hitTestBehavior: HitTestBehavior.translucent,
        onEnter: (_) {
          setState(() {
            _showNotification = true;
          });
        },
        child: const IgnorePointer(
          child: Icon(
            Icons.warning_rounded,
            color: Colors.red,
            size: 22,
          ),
        ),
      );
    }

    return BlocListener<TournamentPlanCubit, TournamentPlanState>(
      listener: (context, state) {
        bool previousTies = tournamentsWithBlockingTies.isNotEmpty;

        setState(() {
          tournamentsWithBlockingTies = _getTournamentsWithBlockingTies(state);
        });

        bool currentTies = tournamentsWithBlockingTies.isNotEmpty;

        if (!previousTies && currentTies) {
          setState(() {
            _showNotification = true;
          });
        }
        if (previousTies && !currentTies) {
          setState(() {
            _showNotification = false;
          });
        }
      },
      child: NavigationTabIcon(
        icon: widget.icon,
        notificationIcon: blockingTieNotificationIcon,
        notification: blockingTieNotification,
      ),
    );
  }

  List<TournamentPlan> _getTournamentsWithBlockingTies(
    TournamentPlanState state,
  ) {
    var withBlockingTies = <TournamentPlan>[];
    for (final tPlan in state.runningTournaments.values) {
      var tournament = tPlan.tournament;
      if (tournament is! GroupKnockout) {
        continue;
      }
      if (tournament.knockoutStarted ||
          !tournament.groupPhase.groupPhaseEnded) {
        continue;
      }

      bool groupTies = tournament.groupPhase.groups.any(
        (group) => group.ties.isNotEmpty,
      );
      bool crossGroupTies = tournament.groupPhase.crossGroupTies.isNotEmpty;

      if (groupTies || crossGroupTies) {
        withBlockingTies.add(tPlan);
      }
    }
    return withBlockingTies;
  }
}
