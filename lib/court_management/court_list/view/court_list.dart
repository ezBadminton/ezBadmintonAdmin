import 'dart:math';

import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/court_management/court_editing/cubit/court_editing_cubit.dart';
import 'package:ez_badminton_admin_app/court_management/court_list/cubit/court_list_cubit.dart';
import 'package:ez_badminton_admin_app/court_management/gymnasium_editing/view/gymnasium_editing_page.dart';
import 'package:ez_badminton_admin_app/widgets/animated_hover/animated_hover.dart';
import 'package:ez_badminton_admin_app/widgets/map_listview/map_listview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CourtList extends StatelessWidget {
  const CourtList({super.key});

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;
    return BlocBuilder<CourtListCubit, CourtListState>(
      buildWhen: (previous, current) => previous.courtMap != current.courtMap,
      builder: (context, state) => CustomMultiChildLayout(
        delegate: _CourtListLayoutDelegate(),
        children: [
          LayoutId(
            id: 'list',
            child: MapListView(
              itemMap: _buildCourtMapItems(context, state.courtMap),
            ),
          ),
          LayoutId(
            id: 'button',
            child: ElevatedButton(
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
          ),
        ],
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
    var cubit = context.read<CourtEditingCubit>();
    return BlocBuilder<CourtEditingCubit, CourtEditingState>(
      buildWhen: (previous, current) => previous.gymnasium != current.gymnasium,
      builder: (context, state) {
        bool selected = gymnasium == state.gymnasium.value;
        return AnimatedHover(
          duration: const Duration(milliseconds: 80),
          builder: (context, animation, child) => SizedBox(
            width: 200,
            child: Column(
              children: [
                child!,
                Divider(
                  height: 0,
                  thickness: 2,
                  indent: selected ? 0 : (1 - animation) * 100,
                  endIndent: selected ? 0 : (1 - animation) * 100,
                  color: Theme.of(context).primaryColor,
                ),
              ],
            ),
          ),
          child: ChoiceChip(
            selectedColor: Theme.of(context).primaryColor.withOpacity(.45),
            onSelected: (_) => cubit.gymnasiumToggled(gymnasium),
            selected: selected,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 5,
              vertical: 10,
            ),
            label: Row(
              children: [
                Text(
                  gymnasium.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCourtItem(BuildContext context, Court court) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextButton(
          onPressed: () {},
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

/// Lays out the court list with its add button
class _CourtListLayoutDelegate extends MultiChildLayoutDelegate {
  @override
  void performLayout(Size size) {
    Size listSize = layoutChild(
      'list',
      BoxConstraints(
        maxHeight: size.height,
        maxWidth: size.width,
      ),
    );
    positionChild('list', Offset((size.width - listSize.width) / 2, 0));
    Size buttonSize = layoutChild(
      'button',
      BoxConstraints(
        maxHeight: size.height,
        maxWidth: size.width,
      ),
    );
    // Position button under list but if list is too long keep button in view
    double buttonYPos = min(listSize.height + 15, size.height - 60);
    positionChild(
      'button',
      Offset((size.width - buttonSize.width) / 2, buttonYPos),
    );
  }

  @override
  bool shouldRelayout(covariant MultiChildLayoutDelegate oldDelegate) {
    return false;
  }
}
