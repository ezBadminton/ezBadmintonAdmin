import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/competition_management/playing_level_editing/cubit/playing_level_editing_cubit.dart';
import 'package:ez_badminton_admin_app/widgets/implicit_animated_list/reorderable_implicit_animated_list.dart';
import 'package:ez_badminton_admin_app/widgets/loading_screen/loading_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class PlayingLevelEditingPopup extends StatelessWidget {
  const PlayingLevelEditingPopup({super.key});

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;
    return BlocProvider(
      create: (context) => PlayingLevelEditingCubit(
        playingLevelRepository:
            context.read<CollectionRepository<PlayingLevel>>(),
        competitionRepository:
            context.read<CollectionRepository<Competition>>(),
      ),
      child: Dialog(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: Padding(
            padding: const EdgeInsets.all(50.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l10n.playingLevel(2),
                  style: const TextStyle(fontSize: 22),
                ),
                const Divider(height: 25, indent: 20, endIndent: 20),
                const _PlayingLevelList(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PlayingLevelList extends StatelessWidget {
  const _PlayingLevelList();

  @override
  Widget build(BuildContext context) {
    var cubit = context.read<PlayingLevelEditingCubit>();
    return BlocBuilder<PlayingLevelEditingCubit, PlayingLevelEditingState>(
      builder: (context, state) {
        return LoadingScreen(
          loadingStatus: state.loadingStatus,
          builder: (context) => SizedBox(
            height: 300,
            child: ReorderableImplicitAnimatedList<PlayingLevel>(
              elements: state.displayPlayingLevels,
              onReorder: cubit.playingLevelsReordered,
              enabled: state.formInteractable,
              duration: const Duration(milliseconds: 120),
              itemBuilder: _itemBuilder,
              itemReorderBuilder: _itemReorderBuilder,
              itemDragBuilder: _itemDragBuilder,
              itemPlaceholderBuilder: _itemPlaceholderBuilder,
            ),
          ),
        );
      },
    );
  }

  Widget _itemPlaceholderBuilder(
    BuildContext context,
    PlayingLevel playingLevel,
    Animation<double> animation,
    DraggableWrapper draggableWrapper,
  ) {
    return Row(
      children: [
        Text(
          playingLevel.name,
          style: TextStyle(color: Theme.of(context).disabledColor),
        ),
        const Expanded(child: SizedBox()),
        draggableWrapper(context, const Icon(Icons.unfold_more)),
      ],
    );
  }

  Widget _itemDragBuilder(
    BuildContext context,
    PlayingLevel playingLevel,
  ) {
    return Text(playingLevel.name);
  }

  Widget _itemReorderBuilder(
    BuildContext context,
    PlayingLevel playingLevel,
    Animation<double> animation,
    DraggableWrapper draggableWrapper,
    int indexDelta,
  ) {
    return SlideTransition(
      position: animation.drive(Tween<Offset>(
        begin: Offset(0, -indexDelta.toDouble() * 1.6666),
        end: Offset.zero,
      )),
      child: Row(
        children: [
          Text(playingLevel.name),
          const Expanded(child: SizedBox()),
          draggableWrapper(context, const Icon(Icons.format_line_spacing)),
        ],
      ),
    );
  }

  Widget _itemBuilder(
    BuildContext context,
    PlayingLevel playingLevel,
    Animation<double> animation,
    DraggableWrapper draggableWrapper,
  ) {
    return SizeTransition(
      sizeFactor: animation,
      child: Row(
        children: [
          Text(playingLevel.name),
          const Expanded(child: SizedBox()),
          draggableWrapper(context, const Icon(Icons.format_line_spacing)),
        ],
      ),
    );
  }
}
