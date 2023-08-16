import 'package:formz/formz.dart';

enum PositiveNonzeroNumberValidationError { negative, zero }

class PositiveNonzeroNumber
    extends FormzInput<int, PositiveNonzeroNumberValidationError> {
  const PositiveNonzeroNumber.pure([super.value = 1]) : super.pure();
  const PositiveNonzeroNumber.dirty([super.value = 1]) : super.dirty();

  @override
  PositiveNonzeroNumberValidationError? validator(int value) {
    if (value < 0) return PositiveNonzeroNumberValidationError.negative;
    if (value == 0) return PositiveNonzeroNumberValidationError.zero;

    return null;
  }
}
