import 'package:email_validator/email_validator.dart';
import 'package:formz/formz.dart';

enum EMailValidationError { empty, format }

class EMailInput extends FormzInput<String, EMailValidationError> {
  const EMailInput.pure({this.emptyAllowed = false, String value = ''})
      : super.pure(value);
  const EMailInput.dirty({this.emptyAllowed = false, String value = ''})
      : super.dirty(value);

  final bool emptyAllowed;

  @override
  EMailValidationError? validator(String value) {
    if (value.isEmpty) {
      return emptyAllowed ? null : EMailValidationError.empty;
    } else if (!EmailValidator.validate(value)) {
      return EMailValidationError.format;
    } else {
      return null;
    }
  }
}
