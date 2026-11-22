import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(Medicamento());
}

class Medicamento extends StatelessWidget {
  const Medicamento({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.green)),
      title: 'Medicamento',
      debugShowCheckedModeBanner: false,
      home: HomeScreen()
    );
  }
}
