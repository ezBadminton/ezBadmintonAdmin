import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/widgets/custom_input_fields/clearable_dropdown_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class PlayingLevelInput extends StatelessWidget {
  const PlayingLevelInput({
    super.key,
    required this.onChanged,
    required this.currentValue,
    required this.playingLevelOptions,
    this.showDeleteButton = true,
  });

  final void Function(PlayingLevel? value) onChanged;
  final PlayingLevel? currentValue;
  final List<PlayingLevel> playingLevelOptions;
  final bool showDeleteButton;

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;
    return ClearableDropdownButton<PlayingLevel>(
      value: currentValue,
      onChanged: onChanged,
      label: Text(l10n.playingLevel),
      items: playingLevelOptions
          .map((level) => DropdownMenuItem(
                value: level,
                child: Text(level.name),
              ))
          .toList(),
    );
  }
}
