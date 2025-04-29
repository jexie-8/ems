import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';
import 'splash_screen.dart';

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
  await Firebase.initializeApp(options: firebaseConfig);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'N.O.H.A',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFE6E0F8), // Light purple everywhere by default!
        textTheme: GoogleFonts.poppinsTextTheme(
          Theme.of(context).textTheme,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color.fromARGB(255, 32, 19, 77), // dark purple default for all AppBars
          iconTheme: IconThemeData(color: Colors.white), // back arrows white everywhere by default
        ),
      ),
      home: const SessionHandler(),
    );
  }
}
