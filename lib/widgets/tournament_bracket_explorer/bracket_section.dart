import 'package:flutter/material.dart';

class BracketSection {
  const BracketSection({
    required this.tournamentDataObject,
    required this.labelBuilder,
  });

  final Object tournamentDataObject;
  final String Function(BuildContext context) labelBuilder;
}
