import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/court_management/gymnasium_editing/utils/gymnasium_court_view_controller.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class GymnasiumCourtViewCubit
    extends Cubit<Map<Gymnasium, GymnasiumCourtViewController>> {
  GymnasiumCourtViewCubit() : super(const {});

  GymnasiumCourtViewController getViewController(Gymnasium gymnasium) {
    if (state.containsKey(gymnasium)) {
      return state[gymnasium]!;
    } else {
      GymnasiumCourtViewController newController =
          GymnasiumCourtViewController(gymnasium: gymnasium);
      var newState = Map.of(state)..putIfAbsent(gymnasium, () => newController);
      emit(newState);
      return newController;
    }
  }
}
