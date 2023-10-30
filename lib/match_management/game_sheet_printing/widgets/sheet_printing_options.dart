import 'package:ez_badminton_admin_app/match_management/game_sheet_printing/cubit/sheet_printing_option_cubit.dart';
import 'package:ez_badminton_admin_app/widgets/cross_fade_drawer/cross_fade_drawer.dart';
import 'package:ez_badminton_admin_app/widgets/help_tooltip_icon/help_tooltip_icon.dart';
import 'package:ez_badminton_admin_app/widgets/loading_screen/loading_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SheetPrintingOptions extends StatelessWidget {
  const SheetPrintingOptions({super.key});

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;
    var cubit = context.read<SheetPrintingOptionCubit>();

    return BlocBuilder<SheetPrintingOptionCubit, SheetPrintingOptionState>(
      builder: (context, state) {
        return LoadingScreen(
          loadingStatus: state.loadingStatus,
          builder: (context) => CrossFadeDrawer(
            controller: cubit.drawerController,
            axis: Axis.vertical,
            expanded: Column(
              children: [
                const _OptionsHeader(),
                CheckboxListTile(
                  title: Text(l10n.dontReprintGameSheets),
                  value: state.dontReprintGameSheets,
                  onChanged: (value) =>
                      cubit.dontReprintGameSheetsChanged(value!),
                  secondary:
                      HelpTooltipIcon(helpText: l10n.dontReprintGameSheetsHelp),
                  controlAffinity: ListTileControlAffinity.leading,
                ),
                CheckboxListTile(
                  title: Text(l10n.printQrCodes),
                  value: state.printQrCodes,
                  onChanged: (value) => cubit.printQrCodesChanged(value!),
                  controlAffinity: ListTileControlAffinity.leading,
                ),
              ],
            ),
            collapsed: const _OptionsHeader(),
          ),
        );
      },
    );
  }
}

class _OptionsHeader extends StatelessWidget {
  const _OptionsHeader()
      : super(key: const ValueKey('sheet_printing_options_header'));

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;
    var cubit = context.read<SheetPrintingOptionCubit>();

    return ListenableBuilder(
      listenable: cubit.drawerController,
      builder: (context, child) => InkWell(
        onTap: cubit.drawerController.isExpanded
            ? cubit.drawerController.collapse
            : cubit.drawerController.expand,
        child: Padding(
          padding: const EdgeInsets.all(3.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                l10n.options,
                style: TextStyle(
                  color:
                      Theme.of(context).colorScheme.onSurface.withOpacity(.6),
                ),
              ),
              AnimatedRotation(
                turns: cubit.drawerController.isExpanded ? 0.5 : 0,
                duration: const Duration(milliseconds: 150),
                child: Icon(
                  Icons.expand_more,
                  color:
                      Theme.of(context).colorScheme.onSurface.withOpacity(.6),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
