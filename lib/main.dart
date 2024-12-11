// Dinithi Mahathanthri
// IM/2021/110
// CourseWork 02

import 'package:flutter/material.dart';
import 'calcualtor.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isDarkMode = false;

  void toggleTheme() {
    setState(() {
      isDarkMode = !isDarkMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: isDarkMode ? ThemeData.dark() : ThemeData.light(),
      debugShowCheckedModeBanner: false,
      home: CalculatorScreen(
        onThemeToggle: toggleTheme,
        isDarkMode: isDarkMode,
      ),
    );
  }
}
