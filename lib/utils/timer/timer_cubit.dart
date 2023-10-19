import 'package:flutter_bloc/flutter_bloc.dart';

part 'timer_state.dart';

class TimerCubit extends Cubit<TimerState> {
  TimerCubit({
    required this.timestamp,
  }) : super(TimerState()) {
    Future.doWhile(_updateTime);
  }

  final DateTime timestamp;

  Future<bool> _updateTime() async {
    final Duration duration =
        DateTime.now().toUtc().difference(timestamp.toUtc());

    emit(TimerState(
      minutes: duration.inMinutes,
      seconds: duration.inSeconds - duration.inMinutes * 60,
    ));

    await Future.delayed(const Duration(seconds: 1));

    return !isClosed;
  }
}
