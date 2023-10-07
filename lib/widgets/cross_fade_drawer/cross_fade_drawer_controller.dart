import 'package:flutter/material.dart';

class CrossFadeDrawerController extends ValueNotifier<bool> {
  CrossFadeDrawerController() : super(true);

  bool get isExpanded => super.value;
  set isExpanded(bool expanded) => super.value = expanded;

  void expand() {
    isExpanded = true;
  }

  void collapse() {
    isExpanded = false;
  }
}
