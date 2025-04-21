import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:ui';
import 'package:google_fonts/google_fonts.dart';
import 'signup_page.dart';

import 'user_screens/exports.dart';


class LoginScreen extends StatefulWidget {


  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String _errorMessage = '';
  bool _obscurePassword = true;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final Map<String, List<String>> rolePaths = {
    'Admin': ['admins', 'admin_users'],
    'Attendee': ['Attendee', 'attendees'],
    'Client': ['Client', 'clients'],
    'Event_Manager': ['employees', 'event_manager'],
    'Accountant': ['employees', 'Accountant'],
    'Custodian': ['employees', 'Custodian'],
    'Security_Safety': ['employees', 'Security_Safety'],
    'Technical_Logistics': ['employees', 'Technical_Logistics'],
    'Tickets_Registration': ['employees', 'ticketeers'],
    'Vendor_Manager': ['employees', 'Vendor_Manager'],
  };
  Future<void> _signIn() async {
    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text;
      final userCredential = await _auth.signInWithEmailAndPassword(email: email, password: password);

      String? userRole;
for (final entry in rolePaths.entries) {
  final path = entry.value;
  print("Checking role: ${entry.key} at path: users/${path[0]}/${path[1]}");

  final snapshot = await _firestore
      .collection("users")
      .doc(path[0])
      .collection(path[1])
      .where("email", isEqualTo: email)
      .limit(1)
      .get();

  for (var doc in snapshot.docs) {
    print("Found user: ${doc.data()}"); // prints all fields in the user document
    print("User email: ${doc['email']}"); // optionally print just the email
  }

  if (snapshot.docs.isNotEmpty) {
    userRole = entry.key;
    break;
  }
}

      if (userRole != null) {
        switch (userRole) {
          case "Admin":
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => AdminDashboard()));
            break;
          case "Event_Manager":
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => EventManagerDashboard()));
            break;
          case "Client":
           Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => ClientDashboard()));
            break;
          case "Tickets_Registration":
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => TicketRegistrationDashboard()));
            break;
          case "Attendee":
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => AttendeeDashboardPage()));
            break;
          case "Custodian":
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => CustodianDashboard()));
            break;
          case "Vendor_Manager":
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => VendorManagerDashboard()));
            break;
          default:
            setState(() => _errorMessage = "No dashboard defined for role: $userRole");
        }
      } else {
        setState(() => _errorMessage = "User role not found.");
      }
    } catch (e) {
      setState(() => _errorMessage = "Error: ${e.toString()}");
    }
  }
@override
Widget build(BuildContext context) {
  return Scaffold(
    body: Stack(
      children: [
        // Background image
        SizedBox.expand(
          child: Image.asset(
            'assets/backgrounds/login_bg.jpg',
            fit: MediaQuery.of(context).size.aspectRatio > 1
                ? BoxFit.cover
                : BoxFit.cover,
          ),
        ),

        // Soft background blur
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
            child: Container(
              color: Colors.black.withOpacity(0.0),
            ),
          ),
        ),

        // Slight dark overlay for readability
        Container(
          color: Colors.black.withOpacity(0.6),
        ),

        // Frosted glass login form (floating & centered)
        Center(
          child: SingleChildScrollView(
            child: Align(
              alignment: Alignment.center,
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 700, // 👈 Adjust this if needed
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white.withOpacity(0.3)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.25),
                              blurRadius: 25,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "Welcome Back",
                              style: GoogleFonts.poppins(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Log in to your account",
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                color: Colors.white60,
                              ),
                            ),
                            const SizedBox(height: 24),
                            TextField(
                              controller: _emailController,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                labelText: "Email",
                                labelStyle: const TextStyle(color: Colors.white70),
                                prefixIcon: const Icon(Icons.email, color: Colors.white),
                                filled: true,
                                fillColor: Colors.white.withOpacity(0.1),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: Colors.deepPurpleAccent),
                                ),
                              ),
                              onSubmitted: (_) => _signIn(),
                            ),
                            const SizedBox(height: 16),
                            TextField(
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              style: const TextStyle(color: Colors.white),
                              onSubmitted: (_) => _signIn(),
                              decoration: InputDecoration(
                                labelText: "Password",
                                labelStyle: const TextStyle(color: Colors.white70),
                                prefixIcon: const Icon(Icons.lock, color: Colors.white),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                                    color: Colors.white,
                                  ),
                                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                                ),
                                filled: true,
                                fillColor: Colors.white.withOpacity(0.1),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: Colors.deepPurpleAccent),
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: ElevatedButton(
                                onPressed: _signIn,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color.fromARGB(255, 29, 20, 69),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                child: Text(
                                  "Login",
                                  style: GoogleFonts.poppins(fontSize: 16, color: Colors.white),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: OutlinedButton(
                                onPressed: () {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(builder: (_) => SignupScreen()),
                                  );
                                },
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: Colors.white),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                child: Text(
                                  "Sign Up",
                                  style: GoogleFonts.poppins(fontSize: 16, color: Colors.white),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            if (_errorMessage.isNotEmpty)
                              Text(
                                _errorMessage,
                                style: const TextStyle(color: Colors.redAccent),
                                textAlign: TextAlign.center,
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}



}