import 'package:formz/formz.dart';

enum NonEmptyError { empty }

class NonEmptyInput extends FormzInput<String, NonEmptyError> {
  const NonEmptyInput.pure([String value = '']) : super.pure(value);
  const NonEmptyInput.dirty([String value = '']) : super.dirty(value);

  @override
  NonEmptyError? validator(String value) {
    if (value.isEmpty) {
      return NonEmptyError.empty;
    } else {
      return null;
    }
  }
}
