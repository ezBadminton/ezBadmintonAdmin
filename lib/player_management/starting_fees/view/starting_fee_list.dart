import 'package:ez_badminton_admin_app/l10n/l10n.dart';
import 'package:ez_badminton_admin_app/player_management/cubit/player_list_cubit.dart';
import 'package:ez_badminton_admin_app/player_management/starting_fees/cubit/starting_fee_cubit.dart';
import 'package:ez_badminton_admin_app/player_management/starting_fees/view/starting_fee_editing_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class StartingFeeList extends StatelessWidget {
  const StartingFeeList({super.key});

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: PlayerListCubit.fromContext),
        BlocProvider(create: StartingFeeCubit.fromContext),
      ],
      child: Scaffold(
        floatingActionButtonLocation: FloatingActionButtonLocation.centerTop,
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(top: 100),
          child: FloatingActionButton.extended(
            onPressed: () {
              Navigator.of(context).push(StartingFeeEditingPage.route());
            },
            label: Text(
              l10n.configureStartingFeesActionButton,
              textAlign: TextAlign.center,
            ),
            icon: Icon(FontAwesomeIcons.coins),
          ),
        ),
        body: Align(
          alignment: Alignment.topCenter,
          child: SizedBox(
            width: 1150,
            child: BlocBuilder<PlayerListCubit, PlayerListState>(
              builder: (context, playerState) {
                return BlocBuilder<StartingFeeCubit, StartingFeeState>(
                  builder: (context, feeState) {
                    return ListView(
                      children: [
                        for (final player in playerState.filteredPlayers)
                          if (feeState.playerFees[player] != null)
                            Text(
                              '${player.lastName}: ${feeState.playerFees[player]}',
                            ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
