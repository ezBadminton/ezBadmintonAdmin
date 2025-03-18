import 'package:ez_badminton_admin_app/tournament_plans/cubit/tournament_plan_cubit.dart';
import 'package:ez_badminton_admin_app/widgets/competition_label/competition_label.dart';
import 'package:ez_badminton_admin_app/widgets/speech_bubble/speech_bubble.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:model_repository/model_repository.dart';

/// The icon for the result tab.
///
/// It can show a notification warning the user of unbroken ties that are
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
  late final LayerLink layerLink;

  late List<TournamentPlan> tournamentsWithBlockingTies;

  OverlayEntry? notificationBubble;

  OverlayEntry? notificationIcon;

  @override
  void initState() {
    super.initState();
    tournamentsWithBlockingTies = [];
    layerLink = LayerLink();
  }

  @override
  void didUpdateWidget(ResultNavigationTabIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.isTabSelected && widget.isTabSelected) {
      hideNotificationBubble();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<TournamentPlanCubit, TournamentPlanState>(
      listener: (context, state) {
        bool previousTies = tournamentsWithBlockingTies.isNotEmpty;

        setState(() {
          tournamentsWithBlockingTies = _getTournamentsWithBlockingTies(state);
        });

        bool currentTies = tournamentsWithBlockingTies.isNotEmpty;

        if (!previousTies && currentTies) {
          showNotficationBubble();
          showNotificationIcon();
        }
        if (previousTies && !currentTies) {
          hideNotificationBubble();
          hideNotificationIcon();
        }
      },
      child: CompositedTransformTarget(
        link: layerLink,
        child: FaIcon(widget.icon),
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

  void showNotficationBubble() {
    if (notificationBubble == null) {
      notificationBubble = _buildNotificationBubble();
      Overlay.of(context).insert(notificationBubble!);
    }
  }

  void hideNotificationBubble() {
    if (notificationBubble != null) {
      notificationBubble!.remove();
      notificationBubble = null;
    }
  }

  void showNotificationIcon() {
    if (notificationIcon == null) {
      notificationIcon = _buildNotificationIcon();
      Overlay.of(context).insert(notificationIcon!);
    }
  }

  void hideNotificationIcon() {
    if (notificationIcon != null) {
      notificationIcon!.remove();
      notificationIcon = null;
    }
  }

  OverlayEntry _buildNotificationBubble() {
    var l10n = AppLocalizations.of(context)!;

    return OverlayEntry(
      builder: (context) => Positioned(
        left: 0,
        top: 0,
        child: DefaultTextStyle(
          style: TextStyle(
            color: Theme.of(context).colorScheme.onPrimary,
          ),
          child: CompositedTransformFollower(
            link: layerLink,
            followerAnchor: Alignment.centerLeft,
            targetAnchor: Alignment.center,
            offset: const Offset(32, 0),
            child: MouseRegion(
              onEnter: (_) {
                hideNotificationBubble();
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
            ),
          ),
        ),
      ),
    );
  }

  OverlayEntry _buildNotificationIcon() {
    return OverlayEntry(
      builder: (context) => Positioned(
        left: 0,
        top: 0,
        child: CompositedTransformFollower(
          link: layerLink,
          followerAnchor: Alignment.center,
          targetAnchor: Alignment.center,
          offset: const Offset(15, 8),
          child: MouseRegion(
            hitTestBehavior: HitTestBehavior.translucent,
            onEnter: (_) {
              showNotficationBubble();
            },
            child: const IgnorePointer(
              child: Icon(
                Icons.warning_rounded,
                color: Colors.red,
                size: 22,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
