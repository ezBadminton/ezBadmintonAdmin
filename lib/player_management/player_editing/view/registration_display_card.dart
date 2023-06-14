import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/player_management/models/competition_registration.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:ez_badminton_admin_app/display_strings/display_strings.dart'
    as display_strings;

class RegistrationDisplayCard extends StatelessWidget {
  const RegistrationDisplayCard(
    this.registration, {
    super.key,
    this.showDeleteButton = false,
    this.onDelete,
    this.showPartnerInput = false,
    this.onPartnerNameChanged,
  })  : assert(showDeleteButton == (onDelete != null)),
        assert(showPartnerInput == (onPartnerNameChanged != null));

  final CompetitionRegistration registration;

  final bool showDeleteButton;
  final void Function(CompetitionRegistration)? onDelete;

  final bool showPartnerInput;
  final void Function(String)? onPartnerNameChanged;

  Competition get competition => registration.competition;

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;
    var divider = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Icon(
        Icons.circle,
        size: 7,
        color: Theme.of(context).colorScheme.onSurface.withOpacity(.5),
      ),
    );
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
        side: BorderSide(
          color: Theme.of(context).colorScheme.onSurface.withOpacity(.3),
          width: 2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (showDeleteButton)
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () => onDelete!(registration),
                  tooltip: l10n.deleteRegistration,
                  icon: const Icon(Icons.close, size: 22),
                ),
              ),
            Column(
              children: [
                Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 240),
                      child: Text(
                        display_strings.playingLevelList(
                          competition.playingLevels,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    divider,
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 140),
                      child: Text(
                        display_strings.ageGroupList(
                          l10n,
                          competition.ageGroups,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    divider,
                    Text(
                      display_strings.competitionCategory(
                        l10n,
                        competition.type,
                        competition.genderCategory,
                      ),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                if (competition.teamSize == 2) ...[
                  const Divider(
                    height: 6,
                    indent: 35,
                    endIndent: 35,
                  ),
                  _DoublesPartner(
                    registration: registration,
                    showPartnerInput: showPartnerInput,
                    onPartnerNameChanged: onPartnerNameChanged,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DoublesPartner extends StatelessWidget {
  const _DoublesPartner({
    required this.registration,
    required this.showPartnerInput,
    required this.onPartnerNameChanged,
  });

  final CompetitionRegistration registration;
  final bool showPartnerInput;
  final void Function(String)? onPartnerNameChanged;

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;
    TextStyle textStyle = const TextStyle(fontSize: 12);
    if (registration.partner == null) {
      if (showPartnerInput) {
        return const Placeholder();
      } else {
        return Text(
          l10n.noPartner,
          style: textStyle,
          textAlign: TextAlign.center,
        );
      }
    } else {
      return Text(
        l10n.withPartner(
          display_strings.playerWithClub(registration.partner!),
        ),
        style: textStyle,
        textAlign: TextAlign.center,
      );
    }
  }
}
