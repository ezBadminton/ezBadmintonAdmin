import 'package:flutter_gen/gen_l10n/app_localizations.dart';

abstract class SectionLabels {
  List<SectionLabel> getSectionLabels(AppLocalizations l10n);
}

class SectionLabel {
  SectionLabel({
    required this.width,
    this.label,
  });

  final double width;
  final String? label;
}
