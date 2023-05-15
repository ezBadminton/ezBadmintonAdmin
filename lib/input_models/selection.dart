import 'package:formz/formz.dart';

enum SelectionValidationError { empty }

class SelectionInput<T> extends FormzInput<T?, SelectionValidationError> {
  const SelectionInput.pure([T? value]) : super.pure(value);
  const SelectionInput.dirty([T? value]) : super.dirty(value);

  @override
  SelectionValidationError? validator(T? value) {
    if (value == null) {
      return SelectionValidationError.empty;
    } else {
      return null;
    }
  }
}
