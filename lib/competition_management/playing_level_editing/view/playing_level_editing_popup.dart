import 'package:collection/collection.dart';
import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/competition_management/playing_level_editing/cubit/playing_level_editing_cubit.dart';
import 'package:ez_badminton_admin_app/constants.dart';
import 'package:ez_badminton_admin_app/widgets/dialog_listener/dialog_listener.dart';
import 'package:ez_badminton_admin_app/widgets/dialogs/confirm_dialog.dart';
import 'package:ez_badminton_admin_app/widgets/dialogs/dropdown_selection_dialog.dart';
import 'package:ez_badminton_admin_app/widgets/implicit_animated_list/reorderable_item_gap.dart';
import 'package:ez_badminton_admin_app/widgets/info_card/info_card.dart';
import 'package:ez_badminton_admin_app/widgets/mouse_hover_builder/mouse_hover_builder.dart';
import 'package:ez_badminton_admin_app/widgets/implicit_animated_list/reorderable_implicit_animated_list.dart';
import 'package:ez_badminton_admin_app/widgets/loading_screen/loading_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
        teamRepository: context.read<CollectionRepository<Team>>(),
      ),
      child: Dialog(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: Padding(
            padding: const EdgeInsets.all(50.0),
            child:
                BlocBuilder<PlayingLevelEditingCubit, PlayingLevelEditingState>(
              builder: (context, state) {
                return LoadingScreen(
                  loadingStatus: state.loadingStatus,
                  builder: (context) => Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        l10n.playingLevel(2),
                        style: const TextStyle(fontSize: 22),
                      ),
                      const Divider(height: 25, indent: 20, endIndent: 20),
                      const _PlayingLevelForm(),
                      const Divider(height: 35, indent: 20, endIndent: 20),
                      const _PlayingLevelList(),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _PlayingLevelForm extends StatelessWidget {
  const _PlayingLevelForm();

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;
    var cubit = context.read<PlayingLevelEditingCubit>();
    return BlocBuilder<PlayingLevelEditingCubit, PlayingLevelEditingState>(
      builder: (context, state) {
        bool areAllCompetitionsNotRunning = state
                .getCollection<Competition>()
                .firstWhereOrNull(
                    (competition) => competition.matches.isNotEmpty) ==
            null;

        if (!areAllCompetitionsNotRunning) {
          return InfoCard(
            child: Text(l10n.categorizationCantBeEdited(l10n.playingLevel(2))),
          );
        }

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
                  controller: cubit.controller,
                  focusNode: cubit.focusNode,
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
    return DialogListener<PlayingLevelEditingCubit, PlayingLevelEditingState,
        bool>(
      builder: (context, state, playingLevel) => ConfirmDialog(
        title: Text(l10n.deleteSubjectQuestion(l10n.playingLevel(1))),
        content: SizedBox(
          width: 500,
          child: Text(l10n.deleteCategoryWarning(
            l10n.playingLevel(1),
            (playingLevel as PlayingLevel).name,
          )),
        ),
        confirmButtonLabel: l10n.confirm,
        cancelButtonLabel: l10n.cancel,
      ),
      child: DialogListener<PlayingLevelEditingCubit, PlayingLevelEditingState,
          PlayingLevel>(
        builder: (context, state, removedPlayingLevel) {
          PlayingLevel noSelectionPlayingLevel =
              PlayingLevel.newPlayingLevel('', -1);
          List<PlayingLevel> replacementOptions = state
              .getCollection<PlayingLevel>()
              .whereNot((playingLevel) => playingLevel == removedPlayingLevel)
              .toList()
            ..insert(0, noSelectionPlayingLevel);
          return DropdownSelectionDialog<PlayingLevel>(
            title: Text(l10n.deleteSubjectQuestion(l10n.playingLevel(1))),
            content: SizedBox(
              width: 500,
              child: Text(l10n.deleteAndMergeCategoryWarning(
                l10n.playingLevel(1),
                (removedPlayingLevel as PlayingLevel).name,
              )),
            ),
            options: replacementOptions,
            displayStringFunction: (playingLevel) =>
                playingLevel.id.isEmpty ? l10n.noSelection : playingLevel.name,
            confirmButtonLabelFunction: (selectedPlayingLevel) =>
                selectedPlayingLevel.id.isEmpty
                    ? l10n.continueWithoutSelection
                    : l10n.confirm,
            cancelButtonLabel: l10n.cancel,
          );
        },
        child: BlocBuilder<PlayingLevelEditingCubit, PlayingLevelEditingState>(
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
                  elementsEqual: _playingLevelsEqual,
                  reorderTooltip: l10n.reorder,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  LoadingStatus _getLoadingStatus(PlayingLevelEditingState state) {
    if (state.hasCollection<PlayingLevel>() &&
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
        begin: Offset(0, -indexDelta.toDouble()),
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

  bool _playingLevelsEqual(
      PlayingLevel playingLevel1, PlayingLevel playingLevel2) {
    return playingLevel1.id == playingLevel2.id &&
        playingLevel1.name == playingLevel2.name;
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

    int playingLevelIndex =
        cubit.state.getCollection<PlayingLevel>().indexOf(playingLevel);

    return Column(
      children: [
        if (playingLevelIndex != 0)
          const Divider(
            height: 1,
            thickness: 1,
          ),
        ReorderableItemGap(
          elementIndex: playingLevelIndex,
          hoveringIndex: hoveringIndex,
          top: true,
          indicatorEndIndent: 85,
        ),
        if (cubit.state.renamingPlayingLevel.value != playingLevel)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: _PlayingLevelDisplayWithControls(
              playingLevel: playingLevel,
              textStyle: textStyle,
              draggableWrapper: draggableWrapper,
              dragIcon: dragIcon,
              hoveringIndex: hoveringIndex,
            ),
          )
        else
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: _PlayingLevelRenameForm(playingLevel: playingLevel),
          ),
        ReorderableItemGap(
          elementIndex: playingLevelIndex,
          hoveringIndex: hoveringIndex,
          top: false,
          indicatorEndIndent: 85,
        ),
      ],
    );
  }
}

class _PlayingLevelRenameForm extends StatelessWidget {
  _PlayingLevelRenameForm({
    required PlayingLevel playingLevel,
  }) {
    _controller.text = playingLevel.name;
    _focus.requestFocus();
  }

  final FocusNode _focus = FocusNode();
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var cubit = context.read<PlayingLevelEditingCubit>();
    var l10n = AppLocalizations.of(context)!;
    return Row(
      children: [
        Expanded(
          child: TextField(
            onChanged: cubit.playingLevelRenameChanged,
            onSubmitted: (_) => cubit.playingLevelRenameFormClosed(),
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
        const SizedBox(width: 20),
        TextButton(
          onPressed: cubit.playingLevelRenameFormClosed,
          child: Text(l10n.done),
        ),
      ],
    );
  }
}

class _PlayingLevelDisplayWithControls extends StatelessWidget {
  const _PlayingLevelDisplayWithControls({
    required this.playingLevel,
    required this.textStyle,
    required this.draggableWrapper,
    required this.dragIcon,
    this.hoveringIndex,
  });

  final PlayingLevel playingLevel;
  final TextStyle? textStyle;
  final DraggableWrapper draggableWrapper;
  final IconData dragIcon;
  final int? hoveringIndex;

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;
    var cubit = context.read<PlayingLevelEditingCubit>();
    bool interactable = cubit.state.formInteractable;
    return MouseHoverBuilder(
      builder: (context, isHovered) => Row(
        children: [
          Text(
            playingLevel.name,
            style: textStyle,
          ),
          const SizedBox(width: 10),
          if (isHovered && hoveringIndex == null && interactable)
            Tooltip(
              message: l10n.rename,
              waitDuration: const Duration(milliseconds: 600),
              triggerMode: TooltipTriggerMode.manual,
              child: InkResponse(
                radius: 16,
                onTap: () {
                  if (interactable) {
                    cubit.playingLevelRenameFormOpened(playingLevel);
                  }
                },
                child: Icon(
                  Icons.edit,
                  size: 19,
                  color: Theme.of(context).disabledColor,
                ),
              ),
            )
          else
            const SizedBox(),
          const Expanded(child: SizedBox(height: 24)),
          if (cubit.state.renamingPlayingLevel.value == null) ...[
            draggableWrapper(
              context,
              Icon(
                dragIcon,
                color: Theme.of(context).disabledColor,
              ),
            ),
            const SizedBox(width: 15),
            BlocBuilder<PlayingLevelEditingCubit, PlayingLevelEditingState>(
              buildWhen: (previous, current) =>
                  previous.getCollection<Competition>() !=
                  current.getCollection<Competition>(),
              builder: (context, state) {
                bool areAllCompetitionsNotRunning = state
                        .getCollection<Competition>()
                        .firstWhereOrNull(
                            (competition) => competition.matches.isNotEmpty) ==
                    null;

                if (!areAllCompetitionsNotRunning) {
                  return const SizedBox();
                }

                return Tooltip(
                  message: l10n.deleteSubject(l10n.playingLevel(1)),
                  waitDuration: const Duration(milliseconds: 600),
                  triggerMode: TooltipTriggerMode.manual,
                  child: InkResponse(
                    radius: 16,
                    onTap: () {
                      if (interactable) {
                        cubit.playingLevelRemoved(playingLevel);
                      }
                    },
                    child: const Icon(Icons.close),
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}
