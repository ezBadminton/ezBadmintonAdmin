import 'dart:convert';

import 'package:ez_badminton_admin_app/l10n/l10n.dart';
import 'package:ez_badminton_admin_app/settings/cubit/certificate_template_settings_cubit.dart';
import 'package:ez_badminton_admin_app/widgets/help_tooltip_icon/help_tooltip_icon.dart';
import 'package:ez_badminton_admin_app/widgets/loading_screen/loading_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';

class CertificateTemplateSettingsPage extends StatelessWidget {
  const CertificateTemplateSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CertificateTemplateSettingsCubit(
        templateStore: context.read(),
      ),
      child: const Align(
        alignment: Alignment.topCenter,
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 30, vertical: 40),
            child: SizedBox(
              width: 650,
              child: _CertificateTemplateForm(),
            ),
          ),
        ),
      ),
    );
  }
}

class _CertificateTemplateForm extends StatefulWidget {
  const _CertificateTemplateForm();

  @override
  State<_CertificateTemplateForm> createState() =>
      _CertificateTemplateFormState();
}

class _CertificateTemplateFormState extends State<_CertificateTemplateForm> {
  late final TextEditingController _titleController;
  late final TextEditingController _fieldsController;

  bool _initialized = false;

  @override
  void initState() {
    _titleController = TextEditingController();
    _fieldsController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _fieldsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;
    var cubit = context.read<CertificateTemplateSettingsCubit>();

    return BlocConsumer<CertificateTemplateSettingsCubit,
        CertificateTemplateSettingsState>(
      listener: (context, state) {
        if (state.formStatus == FormzSubmissionStatus.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.save)),
          );
        }
      },
      builder: (context, state) {
        return LoadingScreen(
          loadingStatus: state.loadingStatus,
          builder: (context) {
            if (!_initialized) {
              _titleController.text = state.template?.title ?? '';
              _fieldsController.text = const JsonEncoder.withIndent('  ')
                  .convert(
                (state.template?.fields ?? const []).map((f) => f.toJson()).toList(),
              );
              _initialized = true;
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      l10n.certificateTemplate,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    HelpTooltipIcon(
                      helpText: l10n.certificateTemplateFieldsHelp,
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: _titleController,
                  onChanged: cubit.titleChanged,
                  decoration: InputDecoration(
                    labelText: l10n.certificateTemplateTitle,
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: _fieldsController,
                  onChanged: cubit.fieldsJsonChanged,
                  maxLines: 14,
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 15),
                if (state.formStatus == FormzSubmissionStatus.failure) ...[
                  Text(
                    l10n.certificateTemplateFieldsInvalid,
                    style: TextStyle(color: Theme.of(context).colorScheme.error),
                  ),
                  const SizedBox(height: 8),
                ],
                ElevatedButton(
                  onPressed: state.formStatus == FormzSubmissionStatus.inProgress
                      ? null
                      : cubit.saved,
                  child: Text(l10n.save),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
