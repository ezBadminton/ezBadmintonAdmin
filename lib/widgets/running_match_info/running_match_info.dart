import 'package:ez_badminton_admin_app/badminton_tournament_ops/badminton_match.dart';
import 'package:ez_badminton_admin_app/widgets/minutes_timer/minutes_timer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:ez_badminton_admin_app/display_strings/display_strings.dart'
    as display_strings;

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
    String? roundName = display_strings.matchRoundName(l10n, match);

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
