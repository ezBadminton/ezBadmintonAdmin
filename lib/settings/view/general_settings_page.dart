import 'package:ez_badminton_admin_app/l10n/l10n.dart';
import 'package:ez_badminton_admin_app/settings/cubit/general_settings_cubit.dart';
import 'package:ez_badminton_admin_app/widgets/loading_screen/loading_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';

class GeneralSettingsPage extends StatelessWidget {
  const GeneralSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => GeneralSettingsCubit(
        tournamentRepository: context.read(),
      ),
      child: const Align(
        alignment: Alignment.topCenter,
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 30, vertical: 40),
            child: SizedBox(
              width: 500,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _TournamentSection(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TournamentSection extends StatelessWidget {
  const _TournamentSection();

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;

    return BlocBuilder<GeneralSettingsCubit, GeneralSettingsState>(
      builder: (context, state) {
        return LoadingScreen(
          loadingStatus: state.loadingStatus,
          builder: (context) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SectionTitle(l10n.tournament),
              const SizedBox(height: 15),
              const _TournamentTitleInput(),
            ],
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
    return Text(
      title,
      style: const TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class _TournamentTitleInput extends StatefulWidget {
  const _TournamentTitleInput();

  @override
  State<_TournamentTitleInput> createState() => _TournamentTitleInputState();
}

class _TournamentTitleInputState extends State<_TournamentTitleInput> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  @override
  void initState() {
    var cubit = context.read<GeneralSettingsCubit>();

    _controller = TextEditingController();
    _focusNode = FocusNode();

    _controller.text = cubit.state.tournamentTitle;

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

    return BlocConsumer<GeneralSettingsCubit, GeneralSettingsState>(
      listenWhen: (previous, current) =>
          current.formStatus != FormzSubmissionStatus.inProgress &&
          current.loadingStatus != LoadingStatus.loading,
      listener: (context, state) {
        if (_controller.text != state.tournamentTitle) {
          _controller.text = state.tournamentTitle;
        }
      },
      buildWhen: (previous, current) =>
          current.loadingStatus != LoadingStatus.loading &&
          previous.tournamentTitle != current.tournamentTitle,
      builder: (context, state) => TextField(
        controller: _controller,
        focusNode: _focusNode,
        style: const TextStyle(fontSize: 16),
        decoration: InputDecoration(
          labelText: l10n.tournamentTitle,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  void _onFocusChange() {
    var cubit = context.read<GeneralSettingsCubit>();

    if (!_focusNode.hasFocus) {
      cubit.tournamentTitleChanged(_controller.text);
    }
  }
}
