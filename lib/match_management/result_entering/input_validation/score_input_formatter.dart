import 'package:flutter/services.dart';

class ScoreInputFormatter extends TextInputFormatter {
  ScoreInputFormatter({this.maxPoints = 30});

  final int maxPoints;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    int score = int.parse(newValue.text);

    if (score > maxPoints) {
      return oldValue;
    }

    return newValue;
  }
}
