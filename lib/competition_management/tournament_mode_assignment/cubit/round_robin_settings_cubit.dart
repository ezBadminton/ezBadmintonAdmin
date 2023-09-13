import 'package:bloc/bloc.dart';
import 'package:collection_repository/collection_repository.dart';

class RoundRobinSettingsCubit extends Cubit<RoundRobinSettings> {
  RoundRobinSettingsCubit(super.initialState);

  void passesChanged(int passes) {
    emit(state.copyWith(passes: passes));
  }
}
