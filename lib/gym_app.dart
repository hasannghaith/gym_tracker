import 'package:flutter/material.dart';
import 'gym_screen.dart';
import 'history_screen.dart';

class GymApp extends StatelessWidget {
  const GymApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gym Tracker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0F0F0F),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF00E676),
          secondary: Color(0xFF00E676),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const GymScreen(),
        '/history': (context) => const HistoryScreen(),
      },
    );
  }
}
