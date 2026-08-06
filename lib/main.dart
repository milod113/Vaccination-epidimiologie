import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'core/theme/epidemiology_theme.dart';
import 'features/epidemiology_home/presentation/screens/epidemiology_home_screen.dart';
import 'injection_container.dart' as di;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('fr_FR');
  await di.initDependencies();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Service d\'Épidémiologie — Plateforme Vaccination',
      debugShowCheckedModeBanner: false,
      theme: EpidemiologyTheme.light,
      home: const EpidemiologyHomeScreen(),
    );
  }
}
