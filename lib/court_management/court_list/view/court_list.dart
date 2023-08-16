import 'dart:math';

import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/court_management/court_list/cubit/court_list_cubit.dart';
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
              onPressed: () {},
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
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        color: Theme.of(context).primaryColor.withOpacity(.7),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
        child: SizedBox(
          width: 170,
          child: Text(
            gymnasium.name,
            style: const TextStyle(color: Colors.black87),
          ),
        ),
      ),
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
