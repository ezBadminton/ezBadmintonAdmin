import 'package:email_validator/email_validator.dart';
import 'package:formz/formz.dart';

enum EMailValidationError { empty, format }

class EMailInput extends FormzInput<String, EMailValidationError> {
  const EMailInput.pure([String value = '']) : super.pure(value);
  const EMailInput.dirty([String value = '']) : super.dirty(value);

  @override
  EMailValidationError? validator(String value) {
    if (value.isEmpty) {
      return EMailValidationError.empty;
    } else if (!EmailValidator.validate(value)) {
      return EMailValidationError.format;
    } else {
      return null;
    }
  }
}
