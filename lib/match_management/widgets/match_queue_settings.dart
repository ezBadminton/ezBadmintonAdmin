import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/match_management/cubit/match_queue_settings_cubit.dart';
import 'package:ez_badminton_admin_app/widgets/cross_fade_drawer/cross_fade_drawer.dart';
import 'package:ez_badminton_admin_app/widgets/cross_fade_drawer/cross_fade_drawer_controller.dart';
import 'package:ez_badminton_admin_app/widgets/help_tooltip_icon/help_tooltip_icon.dart';
import 'package:ez_badminton_admin_app/widgets/loading_screen/loading_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:formz/formz.dart';

class MatchQueueSettings extends StatefulWidget {
  const MatchQueueSettings({super.key});

  @override
  State<MatchQueueSettings> createState() => _MatchQueueSettingsState();
}

class _MatchQueueSettingsState extends State<MatchQueueSettings> {
  late final CrossFadeDrawerController _controller;

  @override
  void initState() {
    _controller = CrossFadeDrawerController(false);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;
    var cubit = context.read<MatchQueueSettingsCubit>();

    return CrossFadeDrawer(
      controller: _controller,
      axis: Axis.vertical,
      collapsed: _SettingsHeader(controller: _controller),
      expanded: BlocBuilder<MatchQueueSettingsCubit, MatchQueueSettingsState>(
        builder: (context, state) {
          return LoadingScreen(
            loadingStatus: state.loadingStatus,
            builder: (context) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SettingsHeader(controller: _controller),
                const SizedBox(height: 25),
                _SectionTitle(l10n.playerRestTime),
                const _RestTimeInput(),
                const SizedBox(height: 25),
                _SectionTitle(l10n.queueModeSetting),
                for (QueueMode queueMode in QueueMode.values)
                  RadioListTile(
                    value: queueMode,
                    groupValue: state.queueMode,
                    onChanged: (_) => cubit.queueModeChanged(queueMode),
                    title: Text(l10n.queueMode(queueMode.toString())),
                    secondary: HelpTooltipIcon(
                      helpText: l10n.queueModeHelp(queueMode.toString()),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SettingsHeader extends StatelessWidget {
  const _SettingsHeader({
    required this.controller,
  }) : super(key: const ValueKey('match_queue_settings_header'));

  final CrossFadeDrawerController controller;

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;

    Color headerColor =
        Theme.of(context).colorScheme.onSurface.withOpacity(.65);

    return ListenableBuilder(
      listenable: controller,
      builder: (context, child) {
        return InkWell(
          onTap:
              controller.isExpanded ? controller.collapse : controller.expand,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 2.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  l10n.settings,
                  style: TextStyle(color: headerColor),
                ),
                AnimatedRotation(
                  turns: controller.isExpanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 150),
                  child: Icon(Icons.expand_more, color: headerColor),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 15.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _RestTimeInput extends StatefulWidget {
  const _RestTimeInput();

  @override
  State<_RestTimeInput> createState() => _RestTimeInputState();
}

class _RestTimeInputState extends State<_RestTimeInput> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  @override
  void initState() {
    var cubit = context.read<MatchQueueSettingsCubit>();

    _controller = TextEditingController();
    _focusNode = FocusNode();

    _controller.text = cubit.state.playerRestTime.toString();

    _focusNode.addListener(_onFocusChange);
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;
    return BlocConsumer<MatchQueueSettingsCubit, MatchQueueSettingsState>(
      listenWhen: (previous, current) =>
          current.formStatus != FormzSubmissionStatus.inProgress,
      listener: (context, state) {
        String restTime = state.playerRestTime.toString();
        if (_controller.text != restTime) {
          _controller.text = restTime;
        }
      },
      buildWhen: (previous, current) =>
          previous.playerRestTime != current.playerRestTime,
      builder: (context, state) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Row(
          children: [
            SizedBox(
              width: 50,
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                style: const TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
                inputFormatters: [
                  LengthLimitingTextInputFormatter(2),
                  FilteringTextInputFormatter.digitsOnly,
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                l10n.minute(state.playerRestTime),
                style: const TextStyle(fontSize: 16),
              ),
            ),
            HelpTooltipIcon(
              helpText: l10n.playerRestTimeHelp(
                l10n.nMinutes(state.playerRestTime),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onFocusChange() {
    var cubit = context.read<MatchQueueSettingsCubit>();

    if (!_focusNode.hasFocus) {
      cubit.playerRestTimeChanged(_controller.text);
    }
  }
}
