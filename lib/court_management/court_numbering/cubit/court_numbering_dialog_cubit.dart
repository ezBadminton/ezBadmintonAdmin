import 'package:ez_badminton_admin_app/court_management/court_numbering/models/court_numbering_type.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'court_numbering_dialog_state.dart';

class CourtNumberingDialogCubit extends Cubit<CourtNumberingDialogState> {
  CourtNumberingDialogCubit() : super(CourtNumberingDialogState());

  void courtNumberingTypeChanged(CourtNumberingType type) {
    emit(state.copyWith(numberingType: type));
  }

  void courtNumberingDirectionChanged(Axis direction) {
    emit(state.copyWith(numberingDirection: direction));
  }

  void courtCountingTypeChanged(CourtCountingType type) {
    emit(state.copyWith(countingType: type));
  }
}
