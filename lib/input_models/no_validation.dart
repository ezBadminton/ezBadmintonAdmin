import 'package:formz/formz.dart';

class NoValidationInput extends FormzInput<String, Object> {
  const NoValidationInput.pure([String value = '']) : super.pure(value);
  const NoValidationInput.dirty([String value = '']) : super.dirty(value);

  @override
  Object? validator(String value) => null;
}
