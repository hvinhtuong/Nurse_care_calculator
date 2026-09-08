import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const NurseCareApp());
}

class NurseCareApp extends StatelessWidget {
  const NurseCareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nurse Care Calculator',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.teal,
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}