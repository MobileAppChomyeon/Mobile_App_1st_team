import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:mobileapp/plantData.dart';
import 'login.dart';
import 'plantSelect.dart';
import 'plantBook.dart';
import 'home_screen.dart';
import 'plantSelectAgain.dart';
import 'goalSetting.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  // final plantService = PlantService();
  // print('데이터 불러와야지');
  // await plantService.addDefaultPlantsIfNeeded();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      // title: 'Firebase Auth Example',
      home: const LoginScreen(),
    );
  }
}
