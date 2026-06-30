import 'dart:async';

import 'package:flutter/material.dart';

import 'state/lawatan_app_state.dart';
import 'ui/app_shell.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final state = await LawatanAppState.load();
  runApp(LawatanTapakApp(state: state));
}

class LawatanTapakApp extends StatelessWidget {
  const LawatanTapakApp({super.key, required this.state});

  final LawatanAppState state;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lawatan Tapak',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0F766E),
        ).copyWith(
          secondary: const Color(0xFFEAB308),
          tertiary: const Color(0xFF2563EB),
        ),
        visualDensity: VisualDensity.standard,
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
        ),
      ),
      home: LawatanAppShell(state: state),
    );
  }
}
