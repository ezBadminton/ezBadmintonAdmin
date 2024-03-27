import 'package:formz/formz.dart';

enum NonEmptyError { empty, tooShort }

class NonEmptyInput extends FormzInput<String, NonEmptyError> {
  const NonEmptyInput.pure({
    String value = '',
    this.minLength = 1,
  }) : super.pure(value);
  const NonEmptyInput.dirty({
    String value = '',
    this.minLength = 1,
  }) : super.dirty(value);

  final int minLength;

  NonEmptyInput copyWith(String newValue) {
    return NonEmptyInput.dirty(value: newValue, minLength: minLength);
  }

  @override
  NonEmptyError? validator(String value) {
    if (value.isEmpty) {
      return NonEmptyError.empty;
    } else if (value.length < minLength) {
      return NonEmptyError.tooShort;
    } else {
      return null;
    }
  }
}
