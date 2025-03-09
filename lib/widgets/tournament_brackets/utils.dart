import 'package:flutter/material.dart';
import 'package:model_repository/model_repository.dart';

Map<Slot, Widget> wrapPlaceholderLabels(
  BuildContext context,
  Map<Slot, String> labels,
) {
  TextStyle placeholderStyle =
      TextStyle(color: Theme.of(context).disabledColor);

  Map<Slot, Widget> placeholders = labels.map((slot, text) {
    Text labelText = Text(
      text,
      style: placeholderStyle,
    );

    return MapEntry(slot, labelText);
  });

  return placeholders;
}

List<int> getRankIndices(List<List<Team>> ranks) {
  int index = 0;
  List<int> rankIndices = [];

  for (List<Object> rank in ranks) {
    rankIndices.add(index);

    index += rank.length;
  }

  return rankIndices;
}
