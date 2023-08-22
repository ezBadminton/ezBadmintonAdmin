import 'package:ez_badminton_admin_app/court_management/court_numbering/cubit/court_numbering_dialog_cubit.dart';
import 'package:ez_badminton_admin_app/court_management/court_numbering/models/court_numbering_type.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CourtNumberingDialog extends StatelessWidget {
  const CourtNumberingDialog({super.key});

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;
    return BlocProvider(
      create: (context) => CourtNumberingDialogCubit(),
      child: BlocBuilder<CourtNumberingDialogCubit, CourtNumberingDialogState>(
        builder: (context, state) {
          var cubit = context.read<CourtNumberingDialogCubit>();
          return AlertDialog(
            title: Text(l10n.numberCourts),
            content: SizedBox(
              width: 350,
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
                    title: Text(l10n.columnWise),
                    value: Axis.vertical,
                    groupValue: state.numberingDirection,
                    onChanged: (direction) =>
                        cubit.courtNumberingDirectionChanged(direction!),
                  ),
                  RadioListTile<Axis>(
                    title: Text(l10n.rowWise),
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
                    title: Text(l10n.onlyGym),
                    value: CourtNumberingType.gymOnly,
                    groupValue: state.numberingType,
                    onChanged: (type) => cubit.courtNumberingTypeChanged(type!),
                  ),
                  RadioListTile<CourtNumberingType>(
                    title: Text(l10n.allGyms),
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
                    title: Text(l10n.skip),
                    value: CourtCountingType.skipUnused,
                    groupValue: state.countingType,
                    onChanged: (type) => cubit.courtCountingTypeChanged(type!),
                  ),
                  RadioListTile<CourtCountingType>(
                    title: Text(l10n.count),
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
