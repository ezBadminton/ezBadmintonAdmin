import 'dart:io';

import 'package:args/args.dart';
import 'package:ez_badminton_admin_app/tls_cert_override.dart';
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

import 'package:ez_badminton_admin_app/assets/pdf_fonts.dart';

import 'app.dart';

void main(List<String> arguments) async {
  WidgetsFlutterBinding.ensureInitialized();
  await PdfFonts.ensureInitialized();
  await windowManager.ensureInitialized();

  await windowManager.setTitle("ezBadminton");

  final argParser = ArgParser()..addOption("address");
  ArgResults argResults = argParser.parse(arguments);
  String? ip = argResults.option("address");

  HttpOverrides.global = PrivateIPCertOverride();

  runApp(App(ip: ip));
}
