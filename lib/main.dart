import 'package:flutter/material.dart';
import 'package:wobbly_wizards/game_shell.dart';

void main() {
  runApp(const WobblyWizardsApp());
}

class WobblyWizardsApp extends StatelessWidget {
  const WobblyWizardsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wobbly Wizards',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6A4C93)),
        fontFamily: 'Cinzel',
      ),
      home: const GameShell(),
    );
  }
}