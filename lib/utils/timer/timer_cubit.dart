import 'package:flutter_bloc/flutter_bloc.dart';

part 'timer_state.dart';

class TimerCubit extends Cubit<TimerState> {
  TimerCubit({
    required this.timestamp,
    this.endTime,
  }) : super(TimerState()) {
    Future.doWhile(_updateTime);
  }

  final DateTime timestamp;

  final DateTime? endTime;

  Future<bool> _updateTime() async {
    final DateTime now = DateTime.now().toUtc();

    final bool timerEnded = endTime == null ? false : now.isAfter(endTime!);

    final DateTime referenceTime = timerEnded ? endTime! : now;

    final Duration duration = referenceTime.difference(timestamp.toUtc());

    emit(TimerState(
      minutes: duration.inMinutes,
      seconds: duration.inSeconds - duration.inMinutes * 60,
    ));

    await Future.delayed(const Duration(seconds: 1));

    return !isClosed && !timerEnded;
  }
}
