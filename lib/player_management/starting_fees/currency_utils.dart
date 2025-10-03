import 'package:flutter/material.dart';
import 'package:sealed_currencies/sealed_currencies.dart';

String formatCurrency(int amount, FiatCurrency currency) {
  final bool hasDecimals = currency.subunitToUnit > 1;
  final int minLength = hasDecimals ? 3 : 1;
  final String rawNumber = amount.toString().padLeft(minLength, '0');
  final StringBuffer buf = StringBuffer();

  for (final (i, char) in rawNumber.characters.indexed) {
    final inverseIndex = rawNumber.length - i - 1;
    if (inverseIndex == 1 && hasDecimals) {
      buf.write(currency.decimalMark);
    } else if (hasDecimals && (inverseIndex - 1) % 3 == 0 && i > 0) {
      buf.write(currency.thousandsSeparator);
    }
    if (!hasDecimals && (inverseIndex + 1) % 3 == 0 && i > 0) {
      buf.write(currency.thousandsSeparator);
    }

    buf.write(char);
  }
  return buf.toString();
}
