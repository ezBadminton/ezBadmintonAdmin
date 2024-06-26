import 'package:ez_badminton_admin_app/input_models/models.dart';
import 'package:ez_badminton_admin_app/login/bloc/login_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';

class LoginForm extends StatelessWidget {
  const LoginForm({super.key});

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;

    return BlocConsumer<LoginBloc, LoginState>(
      listener: (context, state) {
        if (state.status.isFailure) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(AppLocalizations.of(context)!
                    .loginError(state.loginStatusCode)),
              ),
            );
          context.read<LoginBloc>().add(const LoginFailureDismissed());
        }
      },
      builder: (context, state) {
        if (state.registrationStatus == RegistrationStatus.unknown) {
          return const SizedBox();
        }

        String formTitle =
            state.registrationStatus == RegistrationStatus.registered
                ? l10n.login
                : l10n.signUp;

        return Align(
          alignment: const Alignment(0, -1 / 4),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 700),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  formTitle,
                  style: const TextStyle(
                    fontSize: 28,
                    letterSpacing: 3.0,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 60),
                _UsernameInput(),
                const SizedBox(height: 24),
                _PasswordInput(),
                const SizedBox(height: 24),
                if (state.registrationStatus ==
                    RegistrationStatus.notRegistered) ...[
                  _PasswordConfirmationInput(),
                  const SizedBox(height: 24),
                ],
                _SubmitButton(),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _UsernameInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginBloc, LoginState>(
      buildWhen: (previous, current) =>
          previous.username != current.username ||
          previous.showValidationErrors != current.showValidationErrors,
      builder: (context, state) {
        return TextField(
          key: const Key('loginForm_usernameInput_textField'),
          controller: context.read<LoginBloc>().usernameInputController,
          onChanged: (username) =>
              context.read<LoginBloc>().add(LoginUsernameChanged(username)),
          autofocus: true,
          decoration: InputDecoration(
            labelText: AppLocalizations.of(context)!.username,
            errorText: !state.showValidationErrors || state.username.isValid
                ? null
                : AppLocalizations.of(context)!.invalidUsername,
          ),
        );
      },
    );
  }
}

class _PasswordInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginBloc, LoginState>(
      buildWhen: (previous, current) =>
          previous.password != current.password ||
          previous.showValidationErrors != current.showValidationErrors,
      builder: (context, state) {
        return TextField(
          key: const Key('loginForm_passwordInput_textField'),
          controller: context.read<LoginBloc>().passwordInputController,
          onChanged: (password) =>
              context.read<LoginBloc>().add(LoginPasswordChanged(password)),
          onSubmitted: (_) =>
              context.read<LoginBloc>().add(const LoginSubmitted()),
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

  String? getValidationErrorText(AppLocalizations l10n, LoginState state) {
    switch (state) {
      case LoginState(showValidationErrors: false):
        return null;
      case LoginState(password: NonEmptyInput(error: NonEmptyError.empty)):
        return l10n.invalidPassword;
      case LoginState(
          registrationStatus: RegistrationStatus.notRegistered,
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
    return BlocBuilder<LoginBloc, LoginState>(
      buildWhen: (previous, current) =>
          previous.passwordConfirmation != current.passwordConfirmation ||
          previous.showValidationErrors != current.showValidationErrors,
      builder: (context, state) {
        return TextField(
          key: const Key('loginForm_passwordConfirmationInput_textField'),
          controller: context.read<LoginBloc>().passwordConfirmationController,
          onChanged: (password) => context
              .read<LoginBloc>()
              .add(LoginPasswordConfirmationChanged(password)),
          onSubmitted: (_) =>
              context.read<LoginBloc>().add(const LoginSubmitted()),
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
    return BlocBuilder<LoginBloc, LoginState>(
      buildWhen: (previous, current) =>
          previous.registrationStatus != current.registrationStatus ||
          previous.status != current.status ||
          previous.isValid != current.isValid,
      builder: (context, state) {
        var l10n = AppLocalizations.of(context)!;
        String buttonLabel =
            state.registrationStatus == RegistrationStatus.registered
                ? l10n.login
                : l10n.signUp;

        return state.status.isInProgress
            ? const CircularProgressIndicator()
            : ElevatedButton(
                key: const Key('loginForm_submit_raisedButton'),
                onPressed: state.registrationStatus ==
                        RegistrationStatus.unknown
                    ? null
                    : () {
                        context.read<LoginBloc>().add(const LoginSubmitted());
                      },
                child: Text(buttonLabel),
              );
      },
    );
  }
}
