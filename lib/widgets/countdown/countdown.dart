import 'package:ez_badminton_admin_app/utils/timer/timer_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class Countdown extends StatelessWidget {
  const Countdown({
    super.key,
    required this.timestamp,
    this.textStyle,
  });

  final DateTime timestamp;

  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;

    return BlocProvider(
      key: UniqueKey(),
      create: (context) => TimerCubit(timestamp: timestamp),
      child: BlocBuilder<TimerCubit, TimerState>(
        builder: (context, state) {
          int minutes = -state.minutes;
          int seconds = -state.seconds;

          Text countdownText;

          if (minutes < 0 || seconds < 0) {
            countdownText = Text(
              '0:00 ${l10n.minute(2)}',
              style: textStyle,
            );
          } else if (minutes == 0) {
            countdownText = Text(
              '0:${seconds.toString().padLeft(2, '0')} ${l10n.minute(2)}',
              style: textStyle,
            );
          } else {
            countdownText = Text(
              l10n.nMinutes(minutes + 1),
              style: textStyle,
            );
          }

          return countdownText;
        },
      ),
    );
  }
}
