import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'utils/constants.dart';
import 'config.dart';
import 'screens/calendar_screen.dart';

void main() {
  Gemini.init(apiKey: gemini_API_KEY);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Calendar UI w/ Gemini',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const CalendarScreen(),
    );
  }
}
