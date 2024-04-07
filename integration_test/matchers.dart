import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ez_badminton_admin_app/widgets/custom_expansion_panel_list/expansion_panel_list.dart'
    as custom_expansion_panel;

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

class ExpansionPanelListChildren extends CustomMatcher {
  ExpansionPanelListChildren(matcher)
      : super(
          'ExpansionPanelList children',
          'panels',
          matcher,
        );

  @override
  featureValueOf(actual) =>
      (actual as custom_expansion_panel.ExpansionPanelList).children;
}

class IsPanelExpanded extends CustomMatcher {
  IsPanelExpanded(matcher)
      : super(
          'ExpansionPanel with an expanded status of',
          'bool',
          matcher,
        );

  @override
  featureValueOf(actual) => actual.crossFadeState == CrossFadeState.showSecond;
}

class ElementAt extends CustomMatcher {
  ElementAt(this.index, matcher)
      : super(
          'Element at the index $index',
          'int',
          matcher,
        );

  final int index;

  @override
  featureValueOf(actual) => (actual as Iterable).elementAt(index);
}
