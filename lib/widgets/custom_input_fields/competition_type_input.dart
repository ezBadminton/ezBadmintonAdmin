import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/widgets/custom_input_fields/clearable_dropdown_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CompetitionTypeInput extends StatelessWidget {
  const CompetitionTypeInput({
    super.key,
    required this.onChanged,
    required this.currentValue,
    required this.competitionTypeOptions,
    this.showDeleteButton = true,
  });

  final void Function(CompetitionType? value) onChanged;
  final CompetitionType? currentValue;
  final List<CompetitionType> competitionTypeOptions;
  final bool showDeleteButton;

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;
    return ClearableDropdownButton<CompetitionType>(
      value: currentValue,
      onChanged: onChanged,
      label: Text(l10n.competition),
      items: competitionTypeOptions
          .map((type) => DropdownMenuItem(
                value: type,
                child: Text(l10n.competitionType(type.name)),
              ))
          .toList(),
    );
  }
}
