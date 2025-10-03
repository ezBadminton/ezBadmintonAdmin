import 'package:model_repository/model_repository.dart';
import 'package:flutter/material.dart';
import 'package:ez_badminton_admin_app/display_strings/display_strings.dart'
    as display_strings;
import 'package:ez_badminton_admin_app/l10n/l10n.dart';

class CompetitionLabel extends StatelessWidget {
  const CompetitionLabel({
    super.key,
    required this.competition,
    this.nameMode = CompetitionLabelNameMode.full,
    this.playingLevelMaxWidth = 240,
    this.textStyle,
    this.dividerPadding = 10,
    this.dividerSize = 7,
    this.dividerColor,
    this.alignment = MainAxisAlignment.center,
  });

  final Competition competition;
  final CompetitionLabelNameMode nameMode;
  final double playingLevelMaxWidth;

  final TextStyle? textStyle;

  final double dividerPadding;
  final double dividerSize;
  final Color? dividerColor;
  final MainAxisAlignment alignment;

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;

    var divider = Padding(
      padding: EdgeInsets.symmetric(horizontal: dividerPadding),
      child: Icon(
        Icons.circle,
        size: dividerSize,
        color: dividerColor ??
            Theme.of(context).colorScheme.onSurface.withOpacity(.5),
      ),
    );

    final String? categoryName = switch (nameMode) {
      CompetitionLabelNameMode.full => display_strings.competitionGenderAndType(
          l10n,
          competition.genderCategory,
          competition.type,
        ),
      CompetitionLabelNameMode.abbreviated =>
        display_strings.competitionGenderAndTypeAbbreviation(
          l10n,
          competition.genderCategory,
          competition.type,
        ),
      CompetitionLabelNameMode.none => null,
    };

    return Tooltip(
      message: display_strings.competitionLabel(l10n, competition),
      waitDuration: const Duration(milliseconds: 500),
      child: DefaultTextStyle.merge(
        style: textStyle,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: alignment,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (competition.playingLevel != null) ...[
              ConstrainedBox(
                constraints: BoxConstraints(maxWidth: playingLevelMaxWidth),
                child: Text(
                  competition.playingLevel!.name,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (competition.ageGroup != null || categoryName != null) divider,
            ],
            if (competition.ageGroup != null) ...[
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 140),
                child: Text(
                  display_strings.ageGroup(
                    l10n,
                    competition.ageGroup!,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (categoryName != null) divider,
            ],
            if (categoryName != null)
              Text(
                categoryName,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
          ],
        ),
      ),
    );
  }
}

class TwoLineCompetitionLabel extends StatelessWidget {
  const TwoLineCompetitionLabel({
    super.key,
    required this.competition,
  });

  final Competition competition;

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          display_strings.competitionCategory(
            l10n,
            competition,
          ),
        ),
        CompetitionLabel(
          competition: competition,
          nameMode: CompetitionLabelNameMode.none,
          dividerPadding: 6,
          dividerSize: 6,
          textStyle: TextStyle(fontSize: 12),
        ),
      ],
    );
  }
}

enum CompetitionLabelNameMode {
  full,
  abbreviated,
  none,
}
