import 'package:model_repository/model_repository.dart';
import 'package:ez_badminton_admin_app/widgets/custom_input_fields/clearable_dropdown_button.dart';
import 'package:flutter/material.dart';
import 'package:ez_badminton_admin_app/l10n/l10n.dart';

class CompetitionTypeInput extends StatelessWidget {
  const CompetitionTypeInput({
    super.key,
    required this.onChanged,
    required this.currentValue,
    required this.competitionTypeOptions,
    this.showClearButton = true,
    this.errorText,
  });

  final void Function(CompetitionType? value) onChanged;
  final CompetitionType? currentValue;
  final List<CompetitionType> competitionTypeOptions;
  final bool showClearButton;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;
    return ClearableDropdownButton<CompetitionType>(
      value: currentValue,
      onChanged: onChanged,
      label: Text(l10n.competition(1)),
      items: competitionTypeOptions
          .map((type) => DropdownMenuItem(
                value: type,
                child: Text(l10n.competitionType(type.name)),
              ))
          .toList(),
      showClearButton: showClearButton,
      errorText: errorText,
    );
  }
}
