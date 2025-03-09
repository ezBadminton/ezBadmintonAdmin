import 'package:flutter/material.dart';

class ScoreInputController {
  ScoreInputController({
    required this.participantIndex,
    required this.setIndex,
  })  : editingController = TextEditingController(),
        focusNode = FocusNode();

  final int participantIndex;
  final int setIndex;

  final TextEditingController editingController;
  final FocusNode focusNode;

  late final VoidCallback focusLossCallback;
}
