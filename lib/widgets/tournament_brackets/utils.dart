import 'package:flutter/material.dart';
import 'package:tournament_mode/tournament_mode.dart';

Map<MatchParticipant, Widget> wrapPlaceholderLabels(
  BuildContext context,
  Map<MatchParticipant, String> labels,
) {
  TextStyle placeholderStyle =
      TextStyle(color: Theme.of(context).disabledColor);

  Map<MatchParticipant, Widget> placeholders = labels.map((participant, text) {
    Text labelText = Text(
      text,
      style: placeholderStyle,
    );

    return MapEntry(participant, labelText);
  });

  return placeholders;
}
