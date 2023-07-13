// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'checkbox_group_cubit.dart';

class CheckboxGroupState<T extends Object> {
  const CheckboxGroupState({
    required this.allElements,
    this.enabledElements = const [],
    this.invertSuperCheckbox = false,
  });

  final List<T> allElements;
  final List<T> enabledElements;

  final bool invertSuperCheckbox;

  CheckboxGroupState<T> copyWith({
    List<T>? enabledElements,
    bool? invertSuperCheckbox,
  }) {
    return CheckboxGroupState<T>(
      allElements: allElements,
      enabledElements: enabledElements ?? this.enabledElements,
      invertSuperCheckbox: invertSuperCheckbox ?? this.invertSuperCheckbox,
    );
  }
}
