part of 'custom_print_selection_cubit.dart';

class CustomPrintSelectionState with FormzMixin {
  CustomPrintSelectionState({
    required this.selectedMatches,
  });

  final ListInput<BadmintonMatch> selectedMatches;

  CustomPrintSelectionState copyWith({
    ListInput<BadmintonMatch>? selectedMatches,
  }) {
    return CustomPrintSelectionState(
      selectedMatches: selectedMatches ?? this.selectedMatches,
    );
  }

  @override
  List<FormzInput> get inputs => [selectedMatches];
}
