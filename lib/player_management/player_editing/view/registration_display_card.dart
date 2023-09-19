import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/player_management/models/competition_registration.dart';
import 'package:ez_badminton_admin_app/player_management/player_editing/cubit/partner_registration_cubit.dart';
import 'package:ez_badminton_admin_app/player_management/player_editing/cubit/partner_registration_state.dart';
import 'package:ez_badminton_admin_app/widgets/competition_label/competition_label.dart';
import 'package:ez_badminton_admin_app/widgets/custom_input_fields/player_search_input/player_search_input.dart';
import 'package:ez_badminton_admin_app/widgets/loading_screen/loading_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:ez_badminton_admin_app/display_strings/display_strings.dart'
    as display_strings;
import 'package:formz/formz.dart';

class RegistrationDisplayCard extends StatelessWidget {
  const RegistrationDisplayCard(
    this.registration, {
    super.key,
    this.showDeleteButton = false,
    this.onDelete,
    this.showPartnerInput = false,
  }) : assert(
          !showDeleteButton || onDelete != null,
          'No function for the delete button provided',
        );

  final CompetitionRegistration registration;

  final bool showDeleteButton;
  final void Function(CompetitionRegistration)? onDelete;

  final bool showPartnerInput;

  Competition get competition => registration.competition;

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;

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
                CompetitionLabel(competition: competition),
                if (competition.teamSize == 2) ...[
                  const Divider(
                    height: 6,
                    indent: 35,
                    endIndent: 35,
                  ),
                  _DoublesPartner(
                    registration: registration,
                    showPartnerInput: showPartnerInput,
                    showDeleteButton: showDeleteButton,
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
  _DoublesPartner({
    required this.registration,
    required this.showPartnerInput,
    required this.showDeleteButton,
  }) : super(
          key: ValueKey<String>(
            '${registration.player.id}${registration.competition.id}-partnerdisplay',
          ),
        );

  final CompetitionRegistration registration;
  final bool showPartnerInput;
  final bool showDeleteButton;

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;
    TextStyle textStyle = const TextStyle(fontSize: 12);
    if (registration.partner == null) {
      if (showPartnerInput) {
        return BlocProvider(
          create: (context) => PartnerRegistrationCubit(
            registration: registration,
            playerRepository: context.read<CollectionRepository<Player>>(),
            competitionRepository:
                context.read<CollectionRepository<Competition>>(),
            teamRepository: context.read<CollectionRepository<Team>>(),
          ),
          child: _PartnerNameInput(
            registration: registration,
            showDeleteButton: showDeleteButton,
          ),
        );
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

class _PartnerNameInput extends StatelessWidget {
  const _PartnerNameInput({
    required this.registration,
    required this.showDeleteButton,
  });

  final CompetitionRegistration registration;
  final bool showDeleteButton;

  @override
  Widget build(BuildContext context) {
    var cubit = context.read<PartnerRegistrationCubit>();
    var l10n = AppLocalizations.of(context)!;

    return BlocBuilder<PartnerRegistrationCubit, PartnerRegistrationState>(
      buildWhen: (previous, current) =>
          previous.loadingStatus != current.loadingStatus ||
          previous.showPartnerInput != current.showPartnerInput ||
          previous.partner != current.partner,
      builder: (context, state) {
        bool isLoading = state.loadingStatus == LoadingStatus.loading;
        if (state.showPartnerInput) {
          return Row(
            children: [
              Expanded(
                child: PartnerNameInput(
                  player: registration.player,
                  competition: registration.competition,
                  playerCollection:
                      isLoading ? [] : state.getCollection<Player>(),
                  partnerGetter: () => cubit.state.partner.value,
                  onPartnerChanged: cubit.partnerChanged,
                  label: l10n.searchPartner,
                  disabled: isLoading,
                  counterText: null,
                  initialValue: state.partner.value == null ? '' : null,
                ),
              ),
              TextButton(
                onPressed: _getOnPressed(context, state),
                child: Text(l10n.done),
              ),
              // Create space between done button and delete button
              if (showDeleteButton) const SizedBox(width: 40),
            ],
          );
        } else {
          return TextButton(
            onPressed: isLoading
                ? null
                : () => cubit.partnerInputVisibilityChanged(true),
            child: Text(l10n.registerPartner),
          );
        }
      },
    );
  }

  void Function()? _getOnPressed(
    BuildContext context,
    PartnerRegistrationState state,
  ) {
    var cubit = context.read<PartnerRegistrationCubit>();
    if (state.formStatus == FormzSubmissionStatus.inProgress ||
        state.loadingStatus == LoadingStatus.loading) {
      return null;
    }
    if (state.partner.value == null) {
      return () => cubit.partnerInputVisibilityChanged(false);
    } else {
      return cubit.partnerSubmitted;
    }
  }
}
