import 'package:ez_badminton_admin_app/court_management/court_numbering/cubit/court_numbering_dialog_cubit.dart';
import 'package:ez_badminton_admin_app/court_management/court_numbering/models/court_numbering_type.dart';
import 'package:ez_badminton_admin_app/widgets/court_counting_symbols/court_counting_symbols.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CourtNumberingDialog extends StatelessWidget {
  const CourtNumberingDialog({super.key});

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;

    Color activeSymbolColor =
        Theme.of(context).colorScheme.onSurface.withOpacity(.8);
    Color inactiveSymbolColor = Theme.of(context).disabledColor;

    return BlocProvider(
      create: (context) => CourtNumberingDialogCubit(),
      child: BlocBuilder<CourtNumberingDialogCubit, CourtNumberingDialogState>(
        builder: (context, state) {
          var cubit = context.read<CourtNumberingDialogCubit>();
          return AlertDialog(
            title: Text(l10n.numberCourts),
            content: ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 360),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 15),
                  Text(
                    l10n.countingDirection,
                    style: const TextStyle(fontSize: 18),
                  ),
                  RadioListTile<Axis>(
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(l10n.columnWise),
                        NumberingDirectionSymbol(
                          countingDirection: Axis.vertical,
                          color: state.numberingDirection == Axis.vertical
                              ? activeSymbolColor
                              : inactiveSymbolColor,
                        ),
                      ],
                    ),
                    value: Axis.vertical,
                    groupValue: state.numberingDirection,
                    onChanged: (direction) =>
                        cubit.courtNumberingDirectionChanged(direction!),
                  ),
                  RadioListTile<Axis>(
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(l10n.rowWise),
                        NumberingDirectionSymbol(
                          countingDirection: Axis.horizontal,
                          color: state.numberingDirection == Axis.horizontal
                              ? activeSymbolColor
                              : inactiveSymbolColor,
                        ),
                      ],
                    ),
                    value: Axis.horizontal,
                    groupValue: state.numberingDirection,
                    onChanged: (direction) =>
                        cubit.courtNumberingDirectionChanged(direction!),
                  ),
                  const Divider(),
                  Text(
                    l10n.gym(2),
                    style: const TextStyle(fontSize: 18),
                  ),
                  RadioListTile<CourtNumberingType>(
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(l10n.onlyGym),
                        NumberingTypeSymbol(
                          numberingType: CourtNumberingType.gymOnly,
                          color:
                              state.numberingType == CourtNumberingType.gymOnly
                                  ? activeSymbolColor
                                  : inactiveSymbolColor,
                        ),
                      ],
                    ),
                    value: CourtNumberingType.gymOnly,
                    groupValue: state.numberingType,
                    onChanged: (type) => cubit.courtNumberingTypeChanged(type!),
                  ),
                  RadioListTile<CourtNumberingType>(
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(l10n.allGyms),
                        NumberingTypeSymbol(
                          numberingType: CourtNumberingType.global,
                          color:
                              state.numberingType == CourtNumberingType.global
                                  ? activeSymbolColor
                                  : inactiveSymbolColor,
                        ),
                      ],
                    ),
                    value: CourtNumberingType.global,
                    groupValue: state.numberingType,
                    onChanged: (type) => cubit.courtNumberingTypeChanged(type!),
                  ),
                  const Divider(),
                  Text(
                    l10n.emptyCourts,
                    style: const TextStyle(fontSize: 18),
                  ),
                  RadioListTile<CourtCountingType>(
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(l10n.skip),
                        CountingTypeSymbol(
                          countingType: CourtCountingType.skipUnused,
                          color:
                              state.countingType == CourtCountingType.skipUnused
                                  ? activeSymbolColor
                                  : inactiveSymbolColor,
                        ),
                      ],
                    ),
                    value: CourtCountingType.skipUnused,
                    groupValue: state.countingType,
                    onChanged: (type) => cubit.courtCountingTypeChanged(type!),
                  ),
                  RadioListTile<CourtCountingType>(
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(l10n.count),
                        CountingTypeSymbol(
                          countingType: CourtCountingType.countAll,
                          color:
                              state.countingType == CourtCountingType.countAll
                                  ? activeSymbolColor
                                  : inactiveSymbolColor,
                        ),
                      ],
                    ),
                    value: CourtCountingType.countAll,
                    groupValue: state.countingType,
                    onChanged: (type) => cubit.courtCountingTypeChanged(type!),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, state),
                child: Text(l10n.renameSubject(l10n.court(2))),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, null),
                child: Text(l10n.cancel),
              ),
            ],
          );
        },
      ),
    );
  }
}
