import 'package:ez_badminton_admin_app/competition_management/view/competition_list_page.dart';
import 'package:ez_badminton_admin_app/home/cubit/tab_navigation_cubit.dart';
import 'package:ez_badminton_admin_app/home/cubit/tab_navigation_state.dart';
import 'package:ez_badminton_admin_app/home/widgets/navigation_tab_icon.dart';
import 'package:ez_badminton_admin_app/l10n/l10n.dart';
import 'package:ez_badminton_admin_app/predicate_filter/cubit/predicate_filter_cubit.dart';
import 'package:ez_badminton_admin_app/settings/cubit/local_preferences_cubit.dart';
import 'package:ez_badminton_admin_app/widgets/labeled_checkbox/labeled_checkbox.dart';
import 'package:ez_badminton_admin_app/widgets/speech_bubble/speech_bubble.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:model_repository/model_repository.dart';

/// Tab icon for the competitions tab.
///
/// It shows a notification informing the user of active global filters.
class CompetitionNavigationTabIcon extends StatefulWidget {
  const CompetitionNavigationTabIcon({
    super.key,
    required this.icon,
  });

  final IconData icon;

  @override
  State<CompetitionNavigationTabIcon> createState() =>
      _CompetitionNavigationTabIconState();
}

class _CompetitionNavigationTabIconState
    extends State<CompetitionNavigationTabIcon> {
  bool _showNotificationIcon = false;
  bool _showNotification = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final LocalPreferencesCubit preferencesCubit = BlocProvider.of(context);

    Widget? notificationIcon;
    if (_showNotificationIcon) {
      notificationIcon = IgnorePointer(
        child: Icon(
          Icons.filter_alt,
          color: Theme.of(context).colorScheme.primary,
          size: 22,
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
                  child: Text(l10n.globalCompetitionFilterActive),
                ),
                _DoNotShowAgainCheckbox(),
              ],
            ),
          ),
        ),
      );
    }

    return MultiBlocListener(
      listeners: [
        BlocListener<TabNavigationCubit, TabNavigationState>(
          listener: (context, state) {
            bool tabIsAffectedByCompetitionFilter =
                state.selectedIndex == 3 || state.selectedIndex == 5;
            bool showNotificationPreference =
                preferencesCubit.state.showGlobalCompetitionFilterNotification;
            setState(() {
              _showNotification = _showNotificationIcon &&
                  tabIsAffectedByCompetitionFilter &&
                  showNotificationPreference;
            });
          },
        ),
        BlocListener<PredicateFilterCubit<CompetitionListPage>,
            PredicateFilterState>(
          listener: (context, state) {
            bool filterActive = state.filters.containsKey(Competition);
            setState(() {
              _showNotificationIcon = filterActive;
            });
          },
        ),
      ],
      child: NavigationTabIcon(
        icon: widget.icon,
        notificationIcon: notificationIcon,
        notification: notification,
        onNotificationOutsideClicked: () => setState(() {
          _showNotification = false;
        }),
      ),
    );
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
            previous.showGlobalCompetitionFilterNotification !=
            current.showGlobalCompetitionFilterNotification,
        builder: (context, state) {
          final value = state.showGlobalCompetitionFilterNotification;
          return LabeledCheckbox(
            value: !state.showGlobalCompetitionFilterNotification,
            onToggled: () {
              preferencesCubit.competitionFilterNotificationPreferenceChanged(
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
