import 'package:ez_badminton_admin_app/match_management/game_sheet_printing/cubit/game_sheet_printing_cubit.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class GameSheetPreviewTitle extends StatelessWidget {
  const GameSheetPreviewTitle({super.key});

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;

    return BlocBuilder<GameSheetPrintingCubit, GameSheetPrintingState>(
      builder: (context, state) {
        if (state.numSheets == 0) {
          return Text(
            l10n.preview,
            style: const TextStyle(fontSize: 22),
          );
        }

        int numPages = state.numPages ?? 0;

        String pages = l10n.nPages(numPages);
        String sheets = l10n.nSheets(state.numSheets);

        return Text(
          l10n.gameSheetPrintPreview(pages, sheets),
          style: const TextStyle(fontSize: 22),
        );
      },
    );
  }
}
