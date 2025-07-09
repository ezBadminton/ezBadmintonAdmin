import 'dart:io';

import 'package:args/args.dart';
import 'package:ez_badminton_admin_app/tls_cert_override.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

import 'package:ez_badminton_admin_app/assets/pdf_fonts.dart';

import 'app.dart';

void main(List<String> arguments) async {
  final argParser = ArgParser()
    ..addOption("address")
    ..addFlag("version", defaultsTo: false, abbr: "v")
    ..addOption("username", abbr: "u")
    ..addOption("password", abbr: "p");
  ArgResults argResults = argParser.parse(arguments);

  bool showVersion = argResults.flag("version");
  if (showVersion) {
    const String version =
        String.fromEnvironment("VERSION", defaultValue: "dev");
    Logger logger = Logger(
      filter: ProductionFilter(),
      printer: SimplePrinter(),
    );
    logger.i('ezBadminton client version: $version');
    exit(0);
  }

  String? ip = argResults.option("address");
  String? username = argResults.option("username");
  String? password = argResults.option("password");

  Map<String, String> env = Platform.environment;
  ip ??= env["EZBADMINTON_SERVER"];
  username ??= env["EZBADMINTON_USERNAME"];
  password ??= env["EZBADMINTON_PASSWORD"];

  WidgetsFlutterBinding.ensureInitialized();
  await PdfFonts.ensureInitialized();

  HttpOverrides.global = PrivateIPCertOverride();

  runApp(App(
    ip: ip,
    username: username,
    password: password,
  ));
}
