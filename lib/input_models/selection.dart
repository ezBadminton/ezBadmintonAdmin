import 'package:formz/formz.dart';

enum SelectionValidationError { empty }

class SelectionInput<T> extends FormzInput<T?, SelectionValidationError> {
  const SelectionInput.pure({
    this.emptyAllowed = false,
    T? value,
  }) : super.pure(value);
  const SelectionInput.dirty({
    this.emptyAllowed = false,
    T? value,
  }) : super.dirty(value);

  final bool emptyAllowed;

  @override
  SelectionValidationError? validator(T? value) {
    if (value == null) {
      return emptyAllowed ? null : SelectionValidationError.empty;
    } else {
      return null;
    }
  }
}
