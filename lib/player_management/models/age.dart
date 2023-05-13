import 'package:formz/formz.dart';

enum AgeValidationError { nan, negative, overHundret }

class Age extends FormzInput<String, AgeValidationError> {
  const Age.pure([super.value = '']) : super.pure();
  const Age.dirty([super.value = '']) : super.dirty();

  @override
  AgeValidationError? validator(String value) {
    if (value.isEmpty) return null;

    int? number = int.tryParse(value);
    if (number == null) return AgeValidationError.nan;

    if (number < 0) return AgeValidationError.negative;
    if (number >= 100) return AgeValidationError.overHundret;

    return null;
  }
}
