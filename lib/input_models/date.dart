import 'package:formz/formz.dart';

enum DateValidationError { empty, format }

class DateInput extends FormzInput<String, DateValidationError> {
  const DateInput.pure({
    this.dateParser,
    required this.emptyAllowed,
    String value = '',
  }) : super.pure(value);
  const DateInput.dirty({
    this.dateParser,
    required this.emptyAllowed,
    String value = '',
  }) : super.dirty(value);

  final DateTime? Function(String)? dateParser;
  final bool emptyAllowed;

  @override
  DateValidationError? validator(String value) {
    if (value.isEmpty) {
      return emptyAllowed ? null : DateValidationError.empty;
    }
    if (dateParser == null) {
      assert(false, 'Do not call the date validator with no parser supplied');
      return null;
    }

    var parsedDate = dateParser!(value);
    if (parsedDate == null) {
      return DateValidationError.format;
    } else {
      return null;
    }
  }
}
