import 'package:collection/collection.dart';
import 'package:ez_badminton_admin_app/badminton_tournament_ops/badminton_tournament_modes.dart';
import 'package:ez_badminton_admin_app/badminton_tournament_ops/cubit/tournament_progress_cubit.dart';
import 'package:ez_badminton_admin_app/widgets/competition_label/competition_label.dart';
import 'package:ez_badminton_admin_app/widgets/speech_bubble/speech_bubble.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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

  late List<BadmintonTournamentMode> tournamentsWithBlockingTies;

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
    return BlocListener<TournamentProgressCubit, TournamentProgressState>(
      listener: (context, state) {
        bool previousTies = tournamentsWithBlockingTies.isNotEmpty;

        setState(() {
          tournamentsWithBlockingTies = getTournamentsWithBlockingTies(state);
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

  void showNotficationBubble() {
    if (notificationBubble == null) {
      notificationBubble = _buildNotificationBubble();
      Overlay.of(context).insert(notificationBubble!);
    }
  }

  List<BadmintonTournamentMode> getTournamentsWithBlockingTies(
    TournamentProgressState progressState,
  ) {
    List<BadmintonTournamentMode> tournamentsWithTies =
        progressState.runningTournaments.values.where((tournament) {
      if (tournament is! BadmintonGroupKnockout) {
        return false;
      }

      Object? groupWithTies =
          tournament.groupPhase.groupRoundRobins.firstWhereOrNull(
        (group) =>
            group.isCompleted() && group.finalRanking.blockingTies.isNotEmpty,
      );

      bool crossGroupTies = tournament.groupPhase.isCompleted() &&
          tournament.groupPhase.finalRanking.blockingTies.isNotEmpty;

      return groupWithTies != null || crossGroupTies;
    }).toList();

    return tournamentsWithTies;
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
                      for (BadmintonTournamentMode tournament
                          in tournamentsWithBlockingTies)
                        CompetitionLabel(competition: tournament.competition)
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
