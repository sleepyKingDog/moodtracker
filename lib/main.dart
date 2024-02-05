import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'mood_provider.dart'; // Import your MoodProvider
import 'package:moodtracker/screen/home_screen.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => MoodProvider(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mood Tracker',
      home: HomeScreen(),
    );
  }
}
