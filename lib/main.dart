import 'package:flutter/material.dart';
import 'login.dart'; // Login page import

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Login Example',
      theme: ThemeData(
        scaffoldBackgroundColor: const Color.fromARGB(255, 248, 248, 248),
      ),
      home: const LoginPage(), // Set the initial screen to the LoginPage
    );
  }
}
