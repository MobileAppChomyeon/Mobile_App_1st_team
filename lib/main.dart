import 'package:flutter/material.dart';
import 'plantSelect.dart';
import 'plantBook.dart';
import 'home_screen.dart';
import 'plantSelectAgain.dart';
import 'goalSetting.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: PlantSelect(),
    );
  }
}

