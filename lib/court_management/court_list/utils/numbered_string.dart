import 'dart:math';

import 'package:flutter/material.dart';

const List<String> _digits = [
  '0',
  '1',
  '2',
  '3',
  '4',
  '5',
  '6',
  '7',
  '8',
  '9',
];

/// A comparable representation of a String containing numbers.
///
/// The difference to regular String comparison is that positive integers that
/// might be part of the String are seen as one comparable unit.
///
/// Example:
///
/// Normal String sorting:
///  - `String 20`
///  - `String 3`
///
/// [NumberedString] sorting:
///  - `String 3`
///  - `String 20`
class NumberedString implements Comparable<NumberedString> {
  /// Creates a [NumberedString] of [string]
  NumberedString(this.string) {
    _parseComparables();
  }

  final String string;

  @protected
  List<Comparable> get comparables => List.unmodifiable(_comparables);
  final List<Comparable> _comparables = [];

  // Buffers holding consecutive occurences of alphabetical or numerical chars
  final StringBuffer _alphaBuffer = StringBuffer();
  final StringBuffer _numBuffer = StringBuffer();

  void _parseComparables() {
    for (String char in string.characters) {
      _consumeChar(char);
    }

    if (_alphaBuffer.isNotEmpty) {
      _comparables.add(_alphaBuffer.toString());
      _alphaBuffer.clear();
    } else if (_numBuffer.isNotEmpty) {
      _comparables.add(int.parse(_numBuffer.toString()));
      _numBuffer.clear();
    }
  }

  void _consumeChar(String char) {
    bool isDigit = _digits.contains(char);

    if (isDigit && _alphaBuffer.isNotEmpty) {
      _comparables.add(_alphaBuffer.toString());
      _alphaBuffer.clear();
    } else if (!isDigit && _numBuffer.isNotEmpty) {
      _comparables.add(int.parse(_numBuffer.toString()));
      _numBuffer.clear();
    }

    if (isDigit) {
      _numBuffer.write(char);
    } else {
      _alphaBuffer.write(char);
    }
  }

  @override
  int compareTo(NumberedString other) {
    List<Comparable> otherComparables = other.comparables;
    int minLength = min(_comparables.length, otherComparables.length);

    for (int i = 0; i < minLength; i += 1) {
      int comparison = _comparables[i].compareTo(otherComparables[i]);
      if (comparison != 0) {
        return comparison;
      }
    }

    return _comparables.length.compareTo(otherComparables.length);
  }
}
