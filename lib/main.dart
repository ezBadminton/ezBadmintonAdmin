import 'dart:io';

import 'package:args/args.dart';
import 'package:ez_badminton_admin_app/tls_cert_override.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:window_manager/window_manager.dart';

import 'package:ez_badminton_admin_app/assets/pdf_fonts.dart';

import 'app.dart';

void main(List<String> arguments) async {
  WidgetsFlutterBinding.ensureInitialized();
  await PdfFonts.ensureInitialized();
  await windowManager.ensureInitialized();

  await windowManager.setTitle("ezBadminton");

  ServicesBinding.instance.keyboard.addHandler((e) {
    _onKey(e);
    return false;
  });

  final argParser = ArgParser()..addOption("address");
  ArgResults argResults = argParser.parse(arguments);
  String? ip = argResults.option("address");

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
