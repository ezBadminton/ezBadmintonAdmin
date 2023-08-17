import 'package:ez_badminton_admin_app/widgets/toggleable_tween_animation/cubit/tween_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TweenCubit extends Cubit<TweenState> {
  TweenCubit() : super(TweenState());

  void tweenTargetChanged(double target) {
    if (state.targetValue != target) {
      emit(state.copyWith(targetValue: target));
    }
  }

  void currentValueChanged(double current) {
    emit(state.copyWith(currentValue: current));
  }
}
