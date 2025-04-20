import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'event_creation_webpage.dart'; 
import 'user_screens/event_manager_dashboard.dart';
import 'user_screens/attendee_dashboard.dart';
import 'login_page.dart';

// Define your Firebase configuration using FirebaseOptions
const firebaseConfig = FirebaseOptions(
  apiKey: "AIzaSyBCesw1g_HUMdYvRqwyPc9G1brHsE_KYH4",
  authDomain: "ems-cov.firebaseapp.com",
  projectId: "ems-cov",
  storageBucket: "ems-cov.firebasestorage.app",
  messagingSenderId: "47666111045",
  appId: "1:47666111045:web:e0e4ceb697ad4eaf12f92c",
  measurementId: "G-K33F18PXJD",
);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize Firebase with the FirebaseOptions
  await Firebase.initializeApp(options: firebaseConfig);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'A.J.',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.indigo,
      ),
      home: const LoginScreen(),
    );
  }
}
