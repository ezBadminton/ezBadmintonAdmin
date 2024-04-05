import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class TextFieldText extends CustomMatcher {
  TextFieldText(matcher)
      : super(
          'Textfield with text content',
          'text',
          matcher,
        );
  @override
  featureValueOf(actual) => (actual as TextField).controller!.text;
}
