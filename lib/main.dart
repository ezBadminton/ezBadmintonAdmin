import 'dart:io';

import 'package:args/args.dart';
import 'package:ez_badminton_admin_app/tls_cert_override.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:flutter/services.dart';
import 'package:window_manager/window_manager.dart';

import 'package:ez_badminton_admin_app/assets/pdf_fonts.dart';

import 'app.dart';

void main(List<String> arguments) async {
  final argParser = ArgParser()
    ..addOption("address")
    ..addFlag("version", defaultsTo: false, abbr: "v");
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

  WidgetsFlutterBinding.ensureInitialized();
  await PdfFonts.ensureInitialized();
  await windowManager.ensureInitialized();

  await windowManager.setTitle("ezBadminton");

  ServicesBinding.instance.keyboard.addHandler((e) {
    _onKey(e);
    return false;
  });

  if (ip == null) {
    Map<String, String> env = Platform.environment;
    if (env.containsKey("EZBADMINTON_SERVER")) {
      ip = env["EZBADMINTON_SERVER"];
    }
  }

  HttpOverrides.global = PrivateIPCertOverride();

  runApp(App(ip: ip));
}

void _onKey(KeyEvent event) async {
  if (event is! KeyDownEvent) {
    return;
  }
  if (event.logicalKey == LogicalKeyboardKey.f11) {
    bool fullScreen = await windowManager.isFullScreen();
    windowManager.setFullScreen(!fullScreen);
  } else if (event.logicalKey == LogicalKeyboardKey.escape) {
    windowManager.setFullScreen(false);
  }
}
