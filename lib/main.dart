import 'package:flutter/material.dart';
import 'features/splash/screens/loading_screen.dart';

void main() {
  runApp(const ManibelApp());
}

class ManibelApp extends StatelessWidget {
  const ManibelApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ManibelApp',
      debugShowCheckedModeBanner: false,
      home: const LoadingScreen(),
    );
  }
}