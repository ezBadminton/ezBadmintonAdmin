import 'package:ez_badminton_admin_app/badminton_tournament_ops/badminton_match.dart';
import 'package:ez_badminton_admin_app/home/cubit/tab_navigation_cubit.dart';
import 'package:ez_badminton_admin_app/widgets/competition_label/competition_label.dart';
import 'package:ez_badminton_admin_app/widgets/minutes_timer/minutes_timer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:ez_badminton_admin_app/display_strings/display_strings.dart'
    as display_strings;

class MatchInfo extends StatelessWidget {
  const MatchInfo({
    super.key,
    required this.match,
    this.textStyle = const TextStyle(fontSize: 12),
    this.dividerColor,
    this.playingLevelMaxWidth = 50,
  });

  final BadmintonMatch match;

  final TextStyle textStyle;

  final Color? dividerColor;

  final double playingLevelMaxWidth;

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;
    var navigationCubit = context.read<TabNavigationCubit>();

    String? roundName = display_strings.matchName(l10n, match);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CompetitionLabel(
          competition: match.competition,
          abbreviated: true,
          playingLevelMaxWidth: playingLevelMaxWidth,
          textStyle: textStyle,
          dividerPadding: 3,
          dividerSize: 5,
          dividerColor: dividerColor,
        ),
        if (roundName != null) ...[
          const SizedBox(height: 7),
          TextButton(
            onPressed: () => navigationCubit.tabChanged(
              5,
              reason: [match],
              showBackButton: true,
            ),
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              alignment: AlignmentDirectional.centerStart,
            ),
            child: Text(
              roundName,
              style: textStyle,
            ),
          ),
        ],
        if (match.court != null) ...[
          const SizedBox(height: 7),
          Text(
            match.court!.name,
            style: textStyle,
          ),
        ],
      ],
    );
  }
}

class RunningMatchInfo extends StatelessWidget {
  const RunningMatchInfo({
    super.key,
    required this.match,
    this.textStyle = const TextStyle(fontSize: 12),
  });

  final BadmintonMatch match;

  final TextStyle textStyle;

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;
    String? roundName = display_strings.matchName(l10n, match);

    return IntrinsicHeight(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (roundName != null) ...[
            Expanded(
              child: Text(
                roundName,
                style: textStyle,
                textAlign: TextAlign.end,
              ),
            ),
            const VerticalDivider(
              color: Colors.black54,
              indent: 3,
              endIndent: 3,
            ),
          ],
          Expanded(
            child: match.startTime != null
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.playingTime,
                        style: textStyle,
                      ),
                      MinutesTimer(
                        timestamp: match.startTime!,
                        endTime: match.endTime,
                        textStyle: textStyle,
                      ),
                    ],
                  )
                : Text(
                    l10n.matchPlanned,
                    style: textStyle,
                  ),
          ),
        ],
      ),
    );
  }
}
