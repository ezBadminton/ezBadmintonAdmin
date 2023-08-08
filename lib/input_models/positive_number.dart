import 'package:formz/formz.dart';

enum PositiveNumberValidationError { nan, negative }

class PositiveNumber extends FormzInput<String, PositiveNumberValidationError> {
  const PositiveNumber.pure([super.value = '']) : super.pure();
  const PositiveNumber.dirty([super.value = '']) : super.dirty();

  @override
  PositiveNumberValidationError? validator(String value) {
    if (value.isEmpty) return null;

    int? number = int.tryParse(value);
    if (number == null) return PositiveNumberValidationError.nan;

    if (number < 0) return PositiveNumberValidationError.negative;

    return null;
  }
}
