import 'package:flutter/material.dart';
import './screens/login_screen.dart';
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // final brightness = View.of(context).platformDispatcher.platformBrightness;

    return MaterialApp(
      title: 'Flutter Login Demo',
      theme: ThemeData(
        // brightness: brightness,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        textTheme: const TextTheme(
          headlineMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue),
          bodyMedium: TextStyle(fontSize: 16),
        ),
      ),
      home: const LoginScreen(),
    );
  }
}
