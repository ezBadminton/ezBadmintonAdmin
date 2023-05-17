import 'package:flutter/material.dart';
import 'package:formz/formz.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

enum DateValidationError { empty, format }

class DateInput extends FormzInput<String, DateValidationError> {
  const DateInput.pure({
    required this.context,
    required this.emptyAllowed,
    String value = '',
  }) : super.pure(value);
  const DateInput.dirty({
    required this.context,
    required this.emptyAllowed,
    String value = '',
  }) : super.dirty(value);

  final BuildContext context;
  final bool emptyAllowed;

  @override
  DateValidationError? validator(String value) {
    if (value.isEmpty) {
      return emptyAllowed ? null : DateValidationError.empty;
    }

    var parsedDate = MaterialLocalizations.of(context).parseCompactDate(value);
    if (parsedDate == null) {
      return DateValidationError.format;
    } else {
      return null;
    }
  }
}
