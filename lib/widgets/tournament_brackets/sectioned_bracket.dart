import 'package:ez_badminton_admin_app/widgets/tournament_bracket_explorer/bracket_section.dart';
import 'package:flutter/material.dart';

abstract class SectionedBracket implements Widget {
  List<BracketSection> get sections;
  bool get navigatable;
}
