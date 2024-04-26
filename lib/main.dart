import 'package:ez_badminton_admin_app/assets/pdf_fonts.dart';
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await PdfFonts.ensureInitialized();
  await windowManager.ensureInitialized();

  await windowManager.setTitle("ezBadminton");

  runApp(const App());
}
