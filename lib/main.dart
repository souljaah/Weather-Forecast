import 'package:flutter/material.dart';
import 'package:untitled1/pages/home_screen.dart';
import 'home_screen.dart';  // Import the HomeScreen

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weather App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomeScreen(),  // Set HomeScreen as the starting point
    );
  }
}

