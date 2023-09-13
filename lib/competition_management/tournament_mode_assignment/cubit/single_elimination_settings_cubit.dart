import 'package:bloc/bloc.dart';
import 'package:collection_repository/collection_repository.dart';

class SingleEliminationSettingsCubit extends Cubit<SingleEliminationSettings> {
  SingleEliminationSettingsCubit(super.initialState);

  void seedingModeChanged(SeedingMode seedingMode) {
    emit(state.copyWith(seedingMode: seedingMode));
  }
}
