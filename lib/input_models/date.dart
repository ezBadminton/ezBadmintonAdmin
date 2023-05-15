import 'package:flutter/material.dart';
import 'package:formz/formz.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

enum DateValidationError { empty, format }

class DateInput extends FormzInput<String, DateValidationError> {
  const DateInput.pure({
    required this.context,
    String value = '',
  }) : super.pure(value);
  const DateInput.dirty({
    required this.context,
    String value = '',
  }) : super.dirty(value);

  final BuildContext context;

  @override
  DateValidationError? validator(String value) {
    if (value.isEmpty) {
      return DateValidationError.empty;
    }
    // Use context to format the date according to the locale
    var format = DateFormat.yMd(AppLocalizations.of(context)?.localeName);
    try {
      format.parse(value);
    } catch (e) {
      return DateValidationError.format;
    }
    return null;
  }
}
