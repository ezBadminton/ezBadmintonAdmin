import 'package:ez_badminton_admin_app/badminton_tournament_ops/badminton_match.dart';
import 'package:ez_badminton_admin_app/input_models/list_input.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';

part 'custom_print_selection_state.dart';

class CustomPrintSelectionCubit extends Cubit<CustomPrintSelectionState> {
  CustomPrintSelectionCubit({
    required List<BadmintonMatch> initalSelection,
  }) : super(
          CustomPrintSelectionState(
            selectedMatches: ListInput.pure(initalSelection),
          ),
        );

  void matchToggled(BadmintonMatch match) {
    ListInput<BadmintonMatch> newSelection;

    if (state.selectedMatches.value.contains(match)) {
      newSelection = state.selectedMatches.copyWithRemovedValue(match);
    } else {
      newSelection = state.selectedMatches.copyWithAddedValue(match);
    }

    emit(state.copyWith(selectedMatches: newSelection));
  }
}
