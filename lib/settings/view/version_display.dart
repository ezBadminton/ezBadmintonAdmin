import 'package:authentication_repository/authentication_repository.dart';
import 'package:ez_badminton_admin_app/constants.dart';
import 'package:ez_badminton_admin_app/input_models/models.dart';
import 'package:ez_badminton_admin_app/l10n/l10n.dart';
import 'package:ez_badminton_admin_app/settings/cubit/info_screen_user_list_cubit.dart';
import 'package:ez_badminton_admin_app/settings/cubit/info_screen_user_registration_cubit.dart';
import 'package:ez_badminton_admin_app/settings/cubit/version_get_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:model_repository/model_repository.dart';

class VersionDisplayPage extends StatelessWidget {
  const VersionDisplayPage({super.key});

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;
    return BlocProvider(
      create: (context) => VersionGetCubit(
        pocketBase: context
            .read<AuthenticationRepository<OrganizerAuthCollectionName>>()
            .pocketBase,
      ),
      child: Scaffold(
        body: Align(
          alignment: Alignment.topCenter,
          child: SizedBox(
            width: 600,
            child: BlocBuilder<VersionGetCubit, VersionGetState>(
              builder: (context, state) {
                return Column(
                  children: [
                    const SizedBox(height: 40),
                    Text(
                      l10n.version,
                      style: const TextStyle(fontSize: 22),
                    ),
                    const Divider(height: 25, indent: 20, endIndent: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Align(
                            alignment: AlignmentDirectional.centerEnd,
                            child: Padding(
                              padding: const EdgeInsetsDirectional.only(
                                end: 7,
                              ),
                              child: Text('${l10n.clientVersion}:'),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            state.clientVersion,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Align(
                            alignment: AlignmentDirectional.centerEnd,
                            child: Padding(
                              padding: const EdgeInsetsDirectional.only(
                                end: 7,
                              ),
                              child: Text(
                                '${l10n.serverVersion}:',
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            state.serverVersion,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class InfoscreenUserListItem extends StatelessWidget {
  const InfoscreenUserListItem({
    super.key,
    required this.infoscreenUser,
  });

  final InfoscreenUser infoscreenUser;

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;
    var cubit = context.read<InfoScreenUserListCubit>();

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Container(
        color: Colors.black.withAlpha(7),
        child: Row(
          children: [
            const SizedBox(width: 15),
            RichText(
              text: TextSpan(
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 15,
                ),
                children: <InlineSpan>[
                  TextSpan(
                    text: l10n.username,
                    style: TextStyle(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withAlpha(120),
                    ),
                  ),
                  TextSpan(
                    text: ": ",
                    style: TextStyle(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withAlpha(120),
                    ),
                  ),
                  TextSpan(
                    text: infoscreenUser.username,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontFamily: "Lucida Console",
                      backgroundColor: Colors.grey.shade400,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Align(
                alignment: AlignmentDirectional.centerEnd,
                child: IconButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text(l10n.reallyDeleteInfoscreenUser),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: Text(l10n.cancel),
                          ),
                          TextButton(
                            onPressed: () {
                              cubit.userDeleted(infoscreenUser);
                              Navigator.of(context).pop();
                            },
                            child: Text(l10n.confirm),
                          ),
                        ],
                      ),
                    );
                  },
                  tooltip: l10n.deleteSubject(l10n.user),
                  icon: Icon(
                    Icons.delete,
                    color: Colors.red.shade200,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class InfocsreenUserSignUpForm extends StatelessWidget {
  const InfocsreenUserSignUpForm({super.key});

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;
    return BlocProvider(
      create: (context) => InfoScreenUserRegistrationCubit(
        authenticationRepository: context.read(),
      ),
      child: BlocListener<InfoScreenUserRegistrationCubit,
          InfoScreenUserRegistrationState>(
        listenWhen: (previous, current) =>
            previous.status == FormzSubmissionStatus.inProgress &&
            current.status == FormzSubmissionStatus.success,
        listener: (context, state) {
          Navigator.of(context).pop();
        },
        child: AlertDialog(
          title: Text(l10n.signUpInfoscreenUser),
          content: ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 700),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _UsernameInput(),
                const SizedBox(height: 24),
                _PasswordInput(),
                const SizedBox(height: 24),
                _PasswordConfirmationInput(),
                const SizedBox(height: 24),
              ],
            ),
          ),
          actions: [
            _SubmissionErrorText(),
            const SizedBox(width: 25),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(l10n.cancel),
            ),
            const SizedBox(height: 16),
            _SubmitButton(),
          ],
        ),
      ),
    );
  }
}

class _UsernameInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;
    var cubit = context.read<InfoScreenUserRegistrationCubit>();
    return BlocBuilder<InfoScreenUserRegistrationCubit,
        InfoScreenUserRegistrationState>(
      buildWhen: (previous, current) =>
          previous.username != current.username ||
          previous.showValidationErrors != current.showValidationErrors,
      builder: (context, state) {
        return TextField(
          key: const Key('infoscreen_usernameInput_textField'),
          onChanged: cubit.userNameChanged,
          autofocus: true,
          decoration: InputDecoration(
            labelText: AppLocalizations.of(context)!.username,
            errorText: getValidationErrorText(l10n, state),
          ),
        );
      },
    );
  }

  String? getValidationErrorText(
    AppLocalizations l10n,
    InfoScreenUserRegistrationState state,
  ) {
    switch (state) {
      case InfoScreenUserRegistrationState(showValidationErrors: false):
        return null;
      case InfoScreenUserRegistrationState(
          username: NonEmptyInput(error: NonEmptyError.empty),
        ):
        return l10n.invalidUsername;
      case InfoScreenUserRegistrationState(
          username: NonEmptyInput(error: NonEmptyError.tooShort),
        ):
        return l10n.usernameTooShort;
      default:
        return null;
    }
  }
}

class _PasswordInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var cubit = context.read<InfoScreenUserRegistrationCubit>();
    return BlocBuilder<InfoScreenUserRegistrationCubit,
        InfoScreenUserRegistrationState>(
      buildWhen: (previous, current) =>
          previous.password != current.password ||
          previous.showValidationErrors != current.showValidationErrors,
      builder: (context, state) {
        return TextField(
          key: const Key('infoscreen_passwordInput_textField'),
          onChanged: cubit.passwordChanged,
          onSubmitted: (_) => cubit.submitted(),
          obscureText: true,
          decoration: InputDecoration(
            labelText: AppLocalizations.of(context)!.password,
            errorText:
                getValidationErrorText(AppLocalizations.of(context)!, state),
          ),
        );
      },
    );
  }

  String? getValidationErrorText(
    AppLocalizations l10n,
    InfoScreenUserRegistrationState state,
  ) {
    switch (state) {
      case InfoScreenUserRegistrationState(showValidationErrors: false):
        return null;
      case InfoScreenUserRegistrationState(
          password: NonEmptyInput(error: NonEmptyError.empty),
        ):
        return l10n.invalidPassword;
      case InfoScreenUserRegistrationState(
          password: NonEmptyInput(error: NonEmptyError.tooShort),
        ):
        return l10n.passwordTooShort;
      default:
        return null;
    }
  }
}

class _PasswordConfirmationInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var cubit = context.read<InfoScreenUserRegistrationCubit>();
    return BlocBuilder<InfoScreenUserRegistrationCubit,
        InfoScreenUserRegistrationState>(
      buildWhen: (previous, current) =>
          previous.passwordConfirmation != current.passwordConfirmation ||
          previous.showValidationErrors != current.showValidationErrors,
      builder: (context, state) {
        return TextField(
          key: const Key('infoscreen_passwordConfirmationInput_textField'),
          onChanged: cubit.passwordConfirmationChanged,
          onSubmitted: (_) => cubit.submitted(),
          obscureText: true,
          decoration: InputDecoration(
            labelText: AppLocalizations.of(context)!.passwordConfirmation,
            errorText: !state.showValidationErrors ||
                    state.passwordConfirmation.isValid
                ? null
                : AppLocalizations.of(context)!.invalidPasswordConfirmation,
          ),
        );
      },
    );
  }
}

class _SubmitButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;
    var cubit = context.read<InfoScreenUserRegistrationCubit>();
    return BlocBuilder<InfoScreenUserRegistrationCubit,
        InfoScreenUserRegistrationState>(
      buildWhen: (previous, current) =>
          previous.status != current.status ||
          previous.isValid != current.isValid,
      builder: (context, state) {
        return state.status == FormzSubmissionStatus.inProgress
            ? const CircularProgressIndicator()
            : TextButton(
                key: const Key('infoscreen_submit_button'),
                onPressed: cubit.submitted,
                child: Text(l10n.signUp),
              );
      },
    );
  }
}

class _SubmissionErrorText extends StatelessWidget {
  const _SubmissionErrorText();

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;
    return BlocBuilder<InfoScreenUserRegistrationCubit,
        InfoScreenUserRegistrationState>(
      buildWhen: (previous, current) => previous.status != current.status,
      builder: (context, state) {
        return state.status == FormzSubmissionStatus.failure
            ? Text(l10n.signUpError, style: TextStyle(color: Colors.red))
            : const SizedBox();
      },
    );
  }
}
