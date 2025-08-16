import 'package:ez_badminton_admin_app/home/widgets/navigation_tab_icon.dart';
import 'package:ez_badminton_admin_app/l10n/gen/app_localizations.dart';
import 'package:ez_badminton_admin_app/settings/cubit/local_preferences_cubit.dart';
import 'package:ez_badminton_admin_app/tournament_plans/cubit/tournament_plan_cubit.dart';
import 'package:ez_badminton_admin_app/widgets/competition_label/competition_label.dart';
import 'package:ez_badminton_admin_app/widgets/labeled_checkbox/labeled_checkbox.dart';
import 'package:ez_badminton_admin_app/widgets/speech_bubble/speech_bubble.dart';
import 'package:ez_badminton_admin_app/widgets/tournament_brackets/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:model_repository/model_repository.dart';

/// Shows a discoverability hint when a [GroupKnockout] tournament has
/// finished its group phase and the user can use the manual
/// qualification override
class DrawNavigationTabIcon extends StatefulWidget {
  const DrawNavigationTabIcon({
    super.key,
    required this.icon,
    required this.isTabSelected,
  });

  final IconData icon;
  final bool isTabSelected;

  @override
  State<DrawNavigationTabIcon> createState() => _DrawNavigationTabIconState();
}

class _DrawNavigationTabIconState extends State<DrawNavigationTabIcon> {
  List<TournamentPlan> _tournamentsWithFinishedGroupPhase = [];
  bool _showNotificationIcon = false;
  bool _showNotification = false;

  @override
  void didUpdateWidget(DrawNavigationTabIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.isTabSelected && widget.isTabSelected) {
      _showNotification = false;
    }
  }

  void _showNotificationIfPreferred() {
    final LocalPreferencesCubit preferencesCubit = BlocProvider.of(context);
    final showNotificationPreference =
        preferencesCubit.state.showQualificationOverrideNotification;
    if (showNotificationPreference) {
      setState(() {
        _showNotification = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;

    Widget? notificationIcon;
    if (_showNotificationIcon) {
      notificationIcon = MouseRegion(
        hitTestBehavior: HitTestBehavior.translucent,
        onEnter: (_) => _showNotificationIfPreferred(),
        child: IgnorePointer(
          child: Icon(
            Icons.assignment_turned_in_sharp,
            color: Theme.of(context).colorScheme.primary,
            size: 16,
          ),
        ),
      );
    }

    Widget? notification;
    if (_showNotification) {
      notification = Material(
        type: MaterialType.transparency,
        textStyle: TextStyle(color: Colors.white),
        child: SpeechBubble(
          child: SizedBox(
            width: 240,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(l10n.qualificationOverrideAvailable),
                ),
                for (final tournament in _tournamentsWithFinishedGroupPhase)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CompetitionLabel(
                      competition: tournament.competition,
                    ),
                  ),
                _DoNotShowAgainCheckbox(),
              ],
            ),
          ),
        ),
      );
    }

    return BlocListener<TournamentPlanCubit, TournamentPlanState>(
      listener: (context, state) {
        final previousNumFinished = _tournamentsWithFinishedGroupPhase.length;
        final previousHadFinished = previousNumFinished > 0;

        setState(() {
          _tournamentsWithFinishedGroupPhase =
              _getTournamentsWithFinishedGroupPhase(state);
        });

        final hasFinshed = _tournamentsWithFinishedGroupPhase.isNotEmpty;
        final numFinished = _tournamentsWithFinishedGroupPhase.length;
        setState(() => _showNotificationIcon = hasFinshed);

        if (numFinished > previousNumFinished) {
          _showNotificationIfPreferred();
        }

        if (!hasFinshed && previousHadFinished) {
          setState(() {
            _showNotification = false;
          });
        }
      },
      child: NavigationTabIcon(
        icon: widget.icon,
        notificationIcon: notificationIcon,
        notification: notification,
        onNotificationOutsideClicked: () {
          setState(() {
            _showNotification = false;
          });
        },
      ),
    );
  }

  List<TournamentPlan> _getTournamentsWithFinishedGroupPhase(
    TournamentPlanState state,
  ) {
    return state.runningTournaments.values.where((tPlan) {
      if (tPlan.tournament is GroupKnockout) {
        final groupKnockout = tPlan.tournament as GroupKnockout;
        return isQualificationOverrideAvailable(groupKnockout);
      } else {
        return false;
      }
    }).toList();
  }
}

class _DoNotShowAgainCheckbox extends StatelessWidget {
  const _DoNotShowAgainCheckbox();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final LocalPreferencesCubit preferencesCubit = BlocProvider.of(context);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.blueGrey,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(9.8),
          bottomRight: Radius.circular(9.8),
        ),
      ),
      child: BlocBuilder<LocalPreferencesCubit, LocalPreferencesState>(
        buildWhen: (previous, current) =>
            previous.showQualificationOverrideNotification !=
            current.showQualificationOverrideNotification,
        builder: (context, state) {
          final value = state.showQualificationOverrideNotification;
          return LabeledCheckbox(
            value: !state.showQualificationOverrideNotification,
            onToggled: () {
              preferencesCubit
                  .qualificatinoOverrideNotificationPreferenceChanged(
                !value,
              );
            },
            label: Text(
              l10n.doNotShowAgain,
              style: TextStyle(fontSize: 12),
            ),
          );
        },
      ),
    );
  }
}
