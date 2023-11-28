import 'package:ez_badminton_admin_app/utils/timer/timer_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class MinutesTimer extends StatelessWidget {
  const MinutesTimer({
    super.key,
    required this.timestamp,
    this.endTime,
    this.textStyle,
  });

  final DateTime timestamp;

  final DateTime? endTime;

  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;

    return BlocProvider(
      create: (context) => TimerCubit(
        timestamp: timestamp,
        endTime: endTime,
      ),
      child: BlocBuilder<TimerCubit, TimerState>(
        buildWhen: (previous, current) => previous.minutes != current.minutes,
        builder: (context, state) {
          return Text(
            l10n.nMinutes(state.minutes),
            style: textStyle,
          );
        },
      ),
    );
  }
}
