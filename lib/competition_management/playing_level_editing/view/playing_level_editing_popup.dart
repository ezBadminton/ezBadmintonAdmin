import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/competition_management/playing_level_editing/cubit/playing_level_editing_cubit.dart';
import 'package:ez_badminton_admin_app/constants.dart';
import 'package:ez_badminton_admin_app/widgets/implicit_animated_list/reorderable_implicit_animated_list.dart';
import 'package:ez_badminton_admin_app/widgets/loading_screen/loading_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:formz/formz.dart';

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
                _PlayingLevelForm(),
                const Divider(height: 35, indent: 20, endIndent: 20),
                const _PlayingLevelList(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PlayingLevelForm extends StatelessWidget {
  _PlayingLevelForm();

  final FocusNode _focus = FocusNode();
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;
    var cubit = context.read<PlayingLevelEditingCubit>();
    return BlocConsumer<PlayingLevelEditingCubit, PlayingLevelEditingState>(
      listenWhen: (previous, current) =>
          previous.formStatus == FormzSubmissionStatus.inProgress &&
          current.formStatus == FormzSubmissionStatus.success,
      listener: (context, state) {
        cubit.playingLevelNameChanged('');
        _controller.text = '';
        _focus.requestFocus();
      },
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  onChanged: cubit.playingLevelNameChanged,
                  onSubmitted: (_) => cubit.playingLevelSubmitted(),
                  decoration: InputDecoration(
                    hintText: l10n.nameSubject(l10n.playingLevel(1)),
                  ),
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(playingLevelNameMaxLength),
                  ],
                  controller: _controller,
                  focusNode: _focus,
                ),
              ),
              const SizedBox(width: 15),
              ElevatedButton(
                onPressed:
                    state.formSubmittable ? cubit.playingLevelSubmitted : null,
                child: Text(l10n.add),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _PlayingLevelList extends StatelessWidget {
  const _PlayingLevelList();

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;
    var cubit = context.read<PlayingLevelEditingCubit>();
    return BlocBuilder<PlayingLevelEditingCubit, PlayingLevelEditingState>(
      buildWhen: (previous, current) =>
          previous.loadingStatus != current.loadingStatus ||
          previous.displayPlayingLevels != current.displayPlayingLevels ||
          previous.formInteractable != current.formInteractable,
      builder: (context, state) {
        return LoadingScreen(
          loadingStatus: _getLoadingStatus(state),
          builder: (context) => SizedBox(
            height: 300,
            child: ReorderableImplicitAnimatedList<PlayingLevel>(
              elements: state.displayPlayingLevels,
              onReorder: cubit.playingLevelsReordered,
              draggingEnabled: state.formInteractable,
              duration: const Duration(milliseconds: 120),
              itemBuilder: _itemBuilder,
              itemReorderBuilder: _itemReorderBuilder,
              itemDragBuilder: _itemDragBuilder,
              itemPlaceholderBuilder: _itemPlaceholderBuilder,
              reorderTooltip: l10n.reorder,
            ),
          ),
        );
      },
    );
  }

  LoadingStatus _getLoadingStatus(PlayingLevelEditingState state) {
    if (state.collections[PlayingLevel] != null &&
        state.loadingStatus == LoadingStatus.loading) {
      return LoadingStatus.done;
    }
    return state.loadingStatus;
  }

  Widget _itemPlaceholderBuilder(
    BuildContext context,
    PlayingLevel playingLevel,
    Animation<double> animation,
    DraggableWrapper draggableWrapper,
    int? hoveringIndex,
  ) {
    return _PlayingLevelListItem(
      playingLevel: playingLevel,
      draggableWrapper: draggableWrapper,
      dragIcon: Icons.unfold_more,
      textStyle: TextStyle(color: Theme.of(context).disabledColor),
      hoveringIndex: hoveringIndex,
    );
  }

  Widget _itemDragBuilder(
    BuildContext context,
    PlayingLevel playingLevel,
  ) {
    // Position the dragging widget left of the cursor
    return Transform.translate(
      offset: const Offset(-10, -5),
      child: FractionalTranslation(
        translation: const Offset(-1, 0),
        child: Text(playingLevel.name),
      ),
    );
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
      child: _PlayingLevelListItem(
        playingLevel: playingLevel,
        draggableWrapper: draggableWrapper,
      ),
    );
  }

  Widget _itemBuilder(
    BuildContext context,
    PlayingLevel playingLevel,
    Animation<double> animation,
    DraggableWrapper draggableWrapper,
    int? hoveringIndex,
  ) {
    return SizeTransition(
      sizeFactor: animation,
      child: _PlayingLevelListItem(
        playingLevel: playingLevel,
        draggableWrapper: draggableWrapper,
        hoveringIndex: hoveringIndex,
      ),
    );
  }
}

class _PlayingLevelListItem extends StatelessWidget {
  const _PlayingLevelListItem({
    required this.playingLevel,
    required this.draggableWrapper,
    this.dragIcon = Icons.drag_indicator,
    this.textStyle,
    this.hoveringIndex,
  });

  final PlayingLevel playingLevel;
  final IconData dragIcon;
  final DraggableWrapper draggableWrapper;
  final TextStyle? textStyle;
  final int? hoveringIndex;

  @override
  Widget build(BuildContext context) {
    var cubit = context.read<PlayingLevelEditingCubit>();
    var l10n = AppLocalizations.of(context)!;

    bool deletable = cubit.state.formInteractable;
    int playingLevelIndex =
        cubit.state.getCollection<PlayingLevel>().indexOf(playingLevel);

    return Container(
      color: playingLevelIndex % 2 == 1
          ? Theme.of(context).disabledColor.withOpacity(.05)
          : null,
      child: Column(
        children: [
          _PlayingLevelItemGap(
            elementIndex: playingLevelIndex,
            hoveringIndex: hoveringIndex,
            top: true,
          ),
          Row(
            children: [
              const SizedBox(width: 10),
              Text(
                playingLevel.name,
                style: textStyle,
              ),
              const Expanded(child: SizedBox()),
              draggableWrapper(
                context,
                Icon(
                  dragIcon,
                  color: Theme.of(context).disabledColor,
                ),
              ),
              const SizedBox(width: 15),
              Tooltip(
                message: l10n.deleteSubject(l10n.playingLevel(1)),
                waitDuration: const Duration(milliseconds: 600),
                triggerMode: TooltipTriggerMode.manual,
                child: InkResponse(
                  radius: 16,
                  onTap: () {
                    if (deletable) {
                      cubit.playingLevelRemoved(playingLevel);
                    }
                  },
                  child: const Icon(Icons.close),
                ),
              ),
              const SizedBox(width: 10),
            ],
          ),
          _PlayingLevelItemGap(
            elementIndex: playingLevelIndex,
            hoveringIndex: hoveringIndex,
            top: false,
          ),
        ],
      ),
    );
  }
}

class _PlayingLevelItemGap extends StatelessWidget {
  /// A gap between reorderable items that highlights the position where a
  /// hovering item will land if dropped there.
  const _PlayingLevelItemGap({
    required this.elementIndex,
    this.hoveringIndex,
    required this.top,
  });

  final int elementIndex;
  final int? hoveringIndex;

  final bool top;

  @override
  Widget build(BuildContext context) {
    if (top) {
      if (hoveringIndex != null && elementIndex < hoveringIndex!) {
        return const Padding(
          padding: EdgeInsets.only(bottom: 4),
          child: _ReorderIndicator(),
        );
      } else {
        return const SizedBox(height: 6);
      }
    } else {
      if (hoveringIndex != null && elementIndex > hoveringIndex!) {
        return const Padding(
          padding: EdgeInsets.only(top: 8),
          child: _ReorderIndicator(),
        );
      } else {
        return const SizedBox(height: 10);
      }
    }
  }
}

class _ReorderIndicator extends StatelessWidget {
  const _ReorderIndicator();

  @override
  Widget build(BuildContext context) {
    return Divider(
      color: Theme.of(context).primaryColor,
      height: 2,
      thickness: 2,
      indent: 2,
      endIndent: 85,
    );
  }
}
