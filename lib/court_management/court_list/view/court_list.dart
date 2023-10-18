import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/court_management/court_list/cubit/court_list_cubit.dart';
import 'package:ez_badminton_admin_app/court_management/gymnasium_editing/cubit/gymnasium_court_view_cubit.dart';
import 'package:ez_badminton_admin_app/court_management/gymnasium_editing/cubit/gymnasium_selection_cubit.dart';
import 'package:ez_badminton_admin_app/court_management/gymnasium_editing/view/gymnasium_editing_page.dart';
import 'package:ez_badminton_admin_app/home/cubit/tab_navigation_cubit.dart';
import 'package:ez_badminton_admin_app/home/cubit/tab_navigation_state.dart';
import 'package:ez_badminton_admin_app/widgets/choice_chip_tab/choice_chip_tab.dart';
import 'package:ez_badminton_admin_app/widgets/map_listview/map_listview.dart';
import 'package:ez_badminton_admin_app/widgets/sticky_scrollable_follower/sticky_scrollable_follower.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CourtList extends StatelessWidget {
  const CourtList({super.key});

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;
    double listBottomPadding = 200;
    ScrollController controller = ScrollController();

    return BlocListener<TabNavigationCubit, TabNavigationState>(
      listenWhen: (previous, current) =>
          current.selectedIndex == 2 && current.tabChangeReason is MatchData,
      listener: (context, state) {
        var selectionCubit = context.read<GymnasiumSelectionCubit>();
        var listCubit = context.read<CourtListCubit>();
        List<Gymnasium> gyms = listCubit.state.getCollection<Gymnasium>();

        if (selectionCubit.state.gymnasium.value == null && gyms.isNotEmpty) {
          selectionCubit.gymnasiumToggled(gyms.first);
        }
      },
      child: BlocBuilder<CourtListCubit, CourtListState>(
        buildWhen: (previous, current) => previous.courtMap != current.courtMap,
        builder: (context, state) {
          Map<Widget, List<Widget>> courtListWidgets =
              _buildCourtMapItems(context, state.courtMap);
          return StickyScrollableFollower(
            scrollController: controller,
            followerMargin: 30,
            followerOffset:
                courtListWidgets.isEmpty ? 40 : -listBottomPadding + 15,
            scrollable: MapListView(
              itemMap: courtListWidgets,
              topPadding: 25,
              bottomPadding: listBottomPadding,
              controller: controller,
            ),
            follower: ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(GymnasiumEditingPage.route());
              },
              style: const ButtonStyle(
                shape: MaterialStatePropertyAll(StadiumBorder()),
              ),
              child: Padding(
                padding: const EdgeInsets.all(5.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.add),
                    const SizedBox(width: 3),
                    Text(l10n.gym(1)),
                    const SizedBox(width: 6),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Map<Widget, List<Widget>> _buildCourtMapItems(
    BuildContext context,
    Map<Gymnasium, List<Court>> courtMap,
  ) {
    return {
      for (Gymnasium gym in courtMap.keys)
        _buildGymnasiumItem(context, gym):
            courtMap[gym]!.map((c) => _buildCourtItem(context, c)).toList(),
    };
  }

  Widget _buildGymnasiumItem(BuildContext context, Gymnasium gymnasium) {
    var selectionCubit = context.read<GymnasiumSelectionCubit>();
    var viewCubit = context.read<GymnasiumCourtViewCubit>();
    return BlocBuilder<GymnasiumSelectionCubit, GymnasiumSelectionState>(
      buildWhen: (previous, current) => previous.gymnasium != current.gymnasium,
      builder: (context, state) {
        bool selected = gymnasium == state.gymnasium.value;
        return ChoiceChipTab(
          selected: selected,
          onSelected: (_) {
            if (!selected) {
              Future.delayed(
                const Duration(milliseconds: 8),
                () => viewCubit.getViewController(gymnasium).fitToScreen(),
              );
            }
            selectionCubit.gymnasiumToggled(gymnasium);
          },
          label: SizedBox(
            width: 165,
            child: Text(
              gymnasium.name,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCourtItem(BuildContext context, Court court) {
    var selectionCubit = context.read<GymnasiumSelectionCubit>();
    var viewCubit = context.read<GymnasiumCourtViewCubit>();
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextButton(
          onPressed: () {
            if (selectionCubit.state.gymnasium.value == court.gymnasium) {
              viewCubit
                  .getViewController(court.gymnasium)
                  .focusCourtSlot(court.positionY, court.positionX);
            } else {
              selectionCubit.gymnasiumToggled(court.gymnasium);
              Future.delayed(
                const Duration(milliseconds: 8),
                () => viewCubit
                    .getViewController(court.gymnasium)
                    .focusCourtSlot(court.positionY, court.positionX),
              );
            }
          },
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(
              Theme.of(context).primaryColorLight.withOpacity(.5),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 5.0),
            child: SizedBox(
              width: 130,
              child: Text(
                court.name,
                style: const TextStyle(fontSize: 15.5),
                overflow: TextOverflow.ellipsis,
                softWrap: false,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        const Icon(
          Icons.circle,
          color: Colors.green,
        ),
      ],
    );
  }
}
